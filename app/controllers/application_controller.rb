class ApplicationController < ActionController::API

  private

  def current_user
    header = request.headers['Authorization']
    
    return nil if header.blank?
    
    token = header.sub(/^Bearer\s+/i, '')
    payload, = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })

    user = User.find_by(id: payload['id'])
    
    raise StandardError.new("Invalid token") if user.nil?
    
    return nil if Time.now > Time.at(payload['exp'])

    user
  end
end
