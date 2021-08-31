# frozen_string_literal: true

# ApiExceptionModule contains error handling
module ApiExceptionModule
  extend ActiveSupport::Concern

  class MissingAuthToken < StandardError; end

  class InvalidAuthToken < StandardError; end

  class UserAuthenticationError < StandardError; end

  class InsufficientPrivileges < StandardError; end

  included do
    rescue_from Exception, with: :internal_server_error
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from ApiExceptionModule::MissingAuthToken, with: :unauthorized
    rescue_from ApiExceptionModule::InvalidAuthToken, with: :unauthorized
    rescue_from ApiExceptionModule::UserAuthenticationError, with: :unauthorized
    rescue_from ApiExceptionModule::InsufficientPrivileges, with: :unauthorized
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from CanCan::AccessDenied, with: :unauthorized
  end

  private

  # Status code 422 - unprocessable entity
  def unprocessable_entity(error)
    format_json_response({ message: error.message }, :unprocessable_entity)
  end

  # Status code 401 - unauthorized
  def unauthorized(error)
    format_json_response({ message: error.message }, :unauthorized)
  end

  # Status code 404 - resoruce not found
  def not_found(error)
    format_json_response({ message: error.message }, :not_found)
  end

  # Status code 500 - internal server error
  def internal_server_error(_error)
    format_json_response({ message: I18n.t(:something_went_wrong) }, :internal_server_error)
  end
end
