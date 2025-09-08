class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def current_user
    header = request.headers['Authorization']
    
    return nil if header.blank?
    
    token = header.sub(/^Bearer\s+/i, '')
    
    payload, = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })

    user = User.find_by(id: payload['id'])
    
    return nil if Time.now > Time.at(payload['exp'])

    user
  end
end
