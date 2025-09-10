module PageViewable
  extend ActiveSupport::Concern

  included do
    has_many :page_views, as: :pageviewable, dependent: :destroy
  end

  def track_page_view!(user:, controller:, action:, request:, session:, params: {})
    PageView.track!(
      pageviewable: self,
      user: user,
      controller: controller,
      action: action,
      request: request,
      session: session,
      params: params
    )
  end

  def page_view_count
    page_views.count
  end

  def unique_page_view_count
    page_views.distinct.count(:user_id)
  end

  def recent_page_views(limit: 10)
    page_views.includes(:user).recent.limit(limit)
  end

  def page_views_by_period(period: :today)
    case period
    when :today
      page_views.today
    when :week
      page_views.this_week
    when :month
      page_views.this_month
    else
      page_views
    end
  end

  def most_viewed_by_users(limit: 5)
    page_views.joins(:user)
              .group('users.id, users.first_name, users.last_name')
              .count
              .sort_by { |_, count| -count }
              .first(limit)
              .map { |user_data, count| { user: user_data, count: count } }
  end
end
