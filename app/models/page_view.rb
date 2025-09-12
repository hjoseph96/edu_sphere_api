# frozen_string_literal: true

class PageView < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :pageviewable, polymorphic: true, optional: true

  validates :controller_name, :action_name, presence: true
  validates :request_hash, presence: true, uniqueness: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_pageviewable, ->(pageviewable) { where(pageviewable: pageviewable) }
  scope :for_controller_action, ->(controller, action) { where(controller_name: controller, action_name: action) }
  scope :today, -> { where(created_at: Date.current.all_day) }
  scope :this_week, -> { where(created_at: 1.week.ago..Time.current) }
  scope :this_month, -> { where(created_at: 1.month.ago..Time.current) }

  def self.page_views_by_period(period)
    case period
    when :today
      today
    when :week
      this_week
    when :month
      this_month
    else
      all
    end
  end

  def self.track!(pageviewable:, user:, controller:, action:, request:, session:, params: {})
    request_hash = Digest::MD5.hexdigest("#{request.remote_ip}-#{request.user_agent}-#{Time.current.to_i}")

    create(
      pageviewable: pageviewable,
      user: user,
      controller_name: controller,
      action_name: action,
      view_name: "#{controller}/#{action}",
      request_hash: request_hash,
      session_hash: session.id,
      ip_address: request.remote_ip,
      params: params.to_json,
      referrer: request.referer
    )
  rescue StandardError
    # Ignore duplicate requests (same request_hash)
    nil
  end

  def params_hash
    return {} if params.blank?

    JSON.parse(params)
  rescue JSON::ParserError
    {}
  end

  def pageviewable_title
    case pageviewable_type
    when 'Document'
      pageviewable&.title
    else
      pageviewable_type
    end
  end
end
