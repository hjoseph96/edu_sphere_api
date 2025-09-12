# frozen_string_literal: true

class Document < ApplicationRecord
  include PageViewable
  include ActiveStorage::Attachment::Callbacks
  extend FriendlyId

  friendly_id :title, use: :slugged

  belongs_to :author, class_name: 'User', foreign_key: 'user_id'

  has_many :document_editors, dependent: :destroy
  has_many :editors, through: :document_editors, source: :user

  has_one_attached :file

  validates :title, presence: true

  has_paper_trail

  def markdown?
    file.content_type == 'text/markdown'
  end

  def attributes
    super.merge(
      editors: editors.map(&:attributes),
      can_view: markdown?,
      page_view_count: page_view_count,
      total_versions: versions.count,
      significant_versions_count: significant_versions.count,
      version_groups: grouped_versions.map(&:count)
    )
  end

  # Version filtering methods for handling rapid changes
  # These methods help group and filter versions that occur within a specified time threshold

  def sort_versions
    versions.order(created_at: :asc)
  end

  def filtered_versions(threshold_seconds: 5)
    all_versions = versions.order(created_at: :asc).to_a
    return all_versions if all_versions.empty?

    filtered = []
    current_group = [all_versions.first]

    (1...all_versions.length).each do |i|
      current_version = all_versions[i]
      previous_version = all_versions[i - 1]

      time_diff = current_version.created_at - previous_version.created_at

      if time_diff <= threshold_seconds
        # Within threshold, add to current group
        current_group << current_version
      else
        # Outside threshold, finalize current group and start new one
        filtered << current_group.last # Keep only the last version from the group
        current_group = [current_version]
      end
    end

    # Don't forget the last group
    filtered << current_group.last if current_group.any?

    filtered
  end

  def grouped_versions(threshold_seconds: 5)
    all_versions = versions.order(created_at: :asc).to_a
    return [] if all_versions.empty?

    groups = []
    current_group = [all_versions.first]

    (1...all_versions.length).each do |i|
      current_version = all_versions[i]
      previous_version = all_versions[i - 1]

      time_diff = current_version.created_at - previous_version.created_at

      if time_diff <= threshold_seconds
        # Within threshold, add to current group
        current_group << current_version
      else
        # Outside threshold, finalize current group and start new one
        groups << current_group
        current_group = [current_version]
      end
    end

    # Don't forget the last group
    groups << current_group if current_group.any?

    groups
  end

  def significant_versions(threshold_seconds: 5)
    # Returns only the most recent version from each group of rapid changes
    filtered_versions(threshold_seconds: threshold_seconds)
  end

  def version_changes_summary(threshold_seconds: 5)
    groups = grouped_versions(threshold_seconds: threshold_seconds)

    groups.map do |group|
      {
        start_time: group.first.created_at,
        end_time: group.last.created_at,
        duration: group.last.created_at - group.first.created_at,
        version_count: group.length,
        latest_version: group.last,
        changes: group.map(&:object_changes).compact
      }
    end
  end

  def version_history(options = {})
    threshold = options[:threshold_seconds] || 5
    include_filtered = options[:include_filtered] || false
    include_groups = options[:include_groups] || false

    result = {
      total_versions: versions.count,
      filtered_versions: significant_versions(threshold_seconds: threshold).count,
      threshold_seconds: threshold
    }

    if include_filtered
      result[:filtered_versions_list] = significant_versions(threshold_seconds: threshold).map do |version|
        {
          id: version.id,
          created_at: version.created_at,
          event: version.event,
          changes: version.object_changes
        }
      end
    end

    if include_groups
      result[:version_groups] = grouped_versions(threshold_seconds: threshold).map do |group|
        {
          group_size: group.length,
          start_time: group.first.created_at,
          end_time: group.last.created_at,
          duration_seconds: group.last.created_at - group.first.created_at,
          latest_version_id: group.last.id
        }
      end
    end

    result
  end

  def after_attachment_create(attachment)
    case attachment.name
    when 'file'
      # Log the file attachment
      Rails.logger.info "File attached to document #{id}: #{attachment.blob.filename}"

      if markdown.blank? && markdown?
        # Generate markdown if the file is a markdown file
        generate_markdown

        versions.destroy_all
      end

    end
  end

  def upload_markdown
    # Write the markdown to the file
    path = "#{Rails.root}/tmp/storage/#{file.blob.filename}"
    File.write(path, markdown)

    # Attach the file to the document
    file.attach(io: File.open(path), filename: file.blob.filename)

    # Delete the file
    File.delete(path) if save
  end

  private

  def generate_markdown
    # Download the file and store it in the markdown column
    self.markdown = file.download
    save
  end
end
