class Api::V1::SessionsController < ApplicationController
    def create
        user = User.find_by(email: user_params[:email])

        if user && user.valid_password?(user_params[:password])
            render json: { user: user, token: user.generate_jwt }, status: :created
        else
            render json: { errors: "Invalid email or password" }, status: :unprocessable_entity
        end
    end

    private

    def user_params
        params.require(:user).permit(:email, :password)
    end
end