# frozen_string_literal: true

# ApiRequestAuthorize contains authentication of API token
class ApiRequestAuthorize
  def initialize(headers = {})
    @headers = headers
  end

  def authorize
    { user: current_user }
  end

  private

  attr_reader :headers

  def current_user
    @current_user ||= User.find(decoded_user_id)
  rescue ActiveRecord::RecordNotFound => e
    raise ApiExceptionModule::InvalidAuthToken, "#{I18n.t(:invalid_token)}: #{e.message}"
  end

  def jwt_decoded_token
    @jwt_decoded_token ||= JsonApiToken.decode_token(http_token)
  end

  def decoded_user_id
    jwt_decoded_token[:user_id]
  end

  def http_token
    return headers['HTTP_TOKEN'] if headers['HTTP_TOKEN'].present?

    raise ApiExceptionModule::MissingAuthToken, I18n.t(:missing_token)
  end
end
