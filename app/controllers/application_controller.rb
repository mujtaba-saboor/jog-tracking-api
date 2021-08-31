# frozen_string_literal: true

# ApplicationController gets called before each controller
class ApplicationController < ActionController::API
  include ApiExceptionModule
  include ApiResponse

  before_action :authorize_api_request
  attr_reader :current_user

  def authorize_api_request
    response = ApiRequestAuthorize.new(request.headers).authorize
    @current_user = response[:user]
  end
end
