# frozen_string_literal: true

# ApiRequestAuthenticate contains authentication of API token
class ApiRequestAuthenticate
  def initialize(user_email, user_password)
    @user_email = user_email
    @user_password = user_password
  end

  def authenticate
    JsonApiToken.encode_token(user_id: current_user.id)
  end

  private

  attr_reader :user_email, :user_password

  def current_user
    current_user = User.find_by(email: user_email)
    authenticated = current_user.present? && current_user.authenticate(user_password)
    raise(ApiExceptionModule::UserAuthenticationError, I18n.t(:invalid_credentials)) unless authenticated

    current_user
  end
end
