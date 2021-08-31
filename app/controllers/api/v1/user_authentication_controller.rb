# frozen_string_literal: true

# UserAuthenticationController gets called for login
class Api::V1::UserAuthenticationController < ApplicationController
  skip_before_action :authorize_api_request, only: :login

  # POST /api/v1/login
  def login
    user_token = ApiRequestAuthenticate.new(user_auth_params[:email], user_auth_params[:password]).authenticate
    format_json_response(user_auth_token: user_token)
  end

  private

  def user_auth_params
    params.permit(:email, :password)
  end
end
