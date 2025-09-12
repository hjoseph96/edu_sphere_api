# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      def index
        users = User.where(role: :teacher).search(params[:query])

        render json: { users: users.map(&:attributes) }
      end

      def create
        user = User.new(user_params)

        if user.save
          render json: { user: user, token: user.generate_jwt }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :first_name, :last_name)
      end
    end
  end
end
