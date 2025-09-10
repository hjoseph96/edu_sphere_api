class Document < ApplicationRecord
  include PageViewable
  include ActiveStorage::Attachment::Callbacks

  belongs_to :author, class_name: "User", foreign_key: "user_id"

  has_many :document_editors, dependent: :destroy
  has_many :editors, through: :document_editors, source: :user

  has_one_attached :file

  validates :title, presence: true

  has_paper_trail


  def markdown?
    file.content_type == "text/markdown"
  end

  def attributes
    super.merge(
      editors: editors.map(&:attributes),
      can_view: markdown?,
      page_view_count: page_view_count
    )
  end

  def after_attachment_create(attachment)
    case attachment.name
    when 'file'
      # Log the file attachment
      Rails.logger.info "File attached to document #{id}: #{attachment.blob.filename}"
      
      # Generate markdown if the file is a markdown file
      generate_markdown if attachment.blob.content_type == 'text/markdown'
    end
  end

  def upload_markdown
    # Write the markdown to the file
    path = "#{Rails.root}/tmp/storage/#{file.blob.filename}"
    File.open(path, 'w') { |file| file.write(self.markdown) }

    # Attach the file to the document
    self.file.attach(io: File.open(path), filename: file.blob.filename)

    # Delete the file
    File.delete(path) if self.save
  end

  private

  def generate_markdown
    # Download the file and store it in the markdown column
    self.markdown = file.download
    self.save
  end
end
