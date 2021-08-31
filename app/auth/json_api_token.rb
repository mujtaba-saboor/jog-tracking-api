# frozen_string_literal: true

class JsonApiToken
  PRIVATE_SECRET_KEY = Rails.application.secrets.secret_key_base

  def self.decode_token(user_token)
    HashWithIndifferentAccess.new(JWT.decode(user_token, PRIVATE_SECRET_KEY)[0])
  rescue JWT::DecodeError
    raise ApiExceptionModule::InvalidAuthToken, I18n.t(:invalid_credentials)
  end

  def self.encode_token(user_payload, expiry = nil)
    expiry ||= 24.hours.from_now
    user_payload[:exp] = expiry.to_i
    JWT.encode(user_payload, PRIVATE_SECRET_KEY)
  end
end
