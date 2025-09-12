# frozen_string_literal: true

module ApplicationHelper
  def cdn_for(file)
    "https://#{Rails.application.credentials.dig(:aws, :cloudfront, :url)}/#{file.key}"
  end
end
