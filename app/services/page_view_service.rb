class PageViewService
  def self.track_page_view(pageviewable:, user:, controller:, action:, request:, session:, params: {})
    return unless pageviewable&.respond_to?(:track_page_view!)

    pageviewable.track_page_view!(
      user: user,
      controller: controller,
      action: action,
      request: request,
      session: session,
      params: params
    )
  end

  def self.get_analytics_for(pageviewable, period: :today)
    return {} unless pageviewable&.respond_to?(:page_views)

    {
      total_views: pageviewable.page_view_count,
      unique_views: pageviewable.unique_page_view_count,
      period_views: pageviewable.page_views_by_period(period: period).count,
      recent_views: pageviewable.recent_page_views(limit: 10),
      top_viewers: pageviewable.most_viewed_by_users(limit: 5)
    }
  end

  def self.get_user_analytics(user, period: :today)
    user_page_views = PageView.for_user(user).page_views_by_period(period)
    
    {
      total_views: user_page_views.count,
      unique_documents_viewed: user_page_views.distinct.count(:pageview_id),
      views_by_controller: user_page_views.group(:controller_name, :action_name).count,
      recent_activity: user_page_views.includes(:pageviewable).recent.limit(10)
    }
  end

  def self.get_system_analytics(period: :today)
    page_views = PageView.page_views_by_period(period)
    
    {
      total_page_views: page_views.count,
      unique_users: page_views.distinct.count(:user_id),
      most_viewed_documents: page_views.group(:pageviewable_type, :pageviewable_id)
                                      .count
                                      .sort_by { |_, count| -count }
                                      .first(10),
      views_by_controller: page_views.group(:controller_name, :action_name).count,
      views_by_hour: page_views.group_by_hour(:created_at).count
    }
  end
end
