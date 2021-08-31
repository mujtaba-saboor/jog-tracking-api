# frozen_string_literal: true

module HeadersSpecHelper
  def expired_token_generator(user_id)
    JsonApiToken.encode_token({ user_id: user_id }, (Time.now.to_i - 14))
  end

  def invalid_headers
    { 'HTTP_TOKEN' => nil,
      'Content-Type' => 'application/json' }
  end

  def build_sign_up_user
    user = build(:user)
    user.email = 'signup@user.com'
    user
  end

  def create_admin
    user = build(:user)
    user.save
    user.update(role_id: User::ROLES[:admin], email: 'admin@user.com')
    user
  end

  def create_admin_jog
    user = build(:user)
    user.save
    user.update(role_id: User::ROLES[:admin], email: 'adminjog@user.com')
    user
  end

  def create_manager
    user = build(:user)
    user.save
    user.update(role_id: User::ROLES[:manager], email: 'manager@user.com')
    user
  end

  def create_manager_jog
    user = build(:user)
    user.save
    user.update(role_id: User::ROLES[:manager], email: 'managerjog@user.com')
    user
  end

  def create_regular_user
    user = build(:user)
    user.save
    user.update(role_id: User::ROLES[:regular_user], email: 'regular@user.com')
    user
  end

  def create_regular_user_jog
    user = build(:user)
    user.save
    user.update(role_id: User::ROLES[:regular_user], email: 'regularjog@user.com')
    user
  end

  def valid_token_generator(user_id)
    JsonApiToken.encode_token(user_id: user_id)
  end

  def valid_headers(user)
    { 'HTTP_TOKEN' => valid_token_generator(user.id),
      'Content-Type' => 'application/json' }
  end
end
