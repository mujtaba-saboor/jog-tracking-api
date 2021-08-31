# frozen_string_literal: true

# User controls user flows
class User < ApplicationRecord
  has_secure_password

  ROLES = { admin: 1, manager: 2, regular_user: 3 }.freeze
  ROLE_FILTERS = %w[all admin manager regular_user].freeze
  PER_PAGE = 10
  ROLE_NAMES = { '1' => 'Administrator',
                 '2' => 'Manager',
                 '3' => 'Regular User' }.freeze

  validates_presence_of :name, :email, :password_digest, :role_id
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :role_id, inclusion: { in: ROLES.values }

  has_many :jogging_events, dependent: :destroy

  def profile(current_user)
    raise ApiExceptionModule::InsufficientPrivileges, I18n.t(:cannot_take_following_action) if admin_or_manager? && current_user.manager? && current_user.id != id

    { profile: { id: id,
                 name: name,
                 email: email,
                 role: ROLE_NAMES[role_id.to_s] } }
  end

  def update_profile(params, current_user)
    update!(params)
    { message: I18n.t(:profile_updated) }.merge!(profile(current_user))
  rescue StandardError => e
    { message: "#{I18n.t(:profile_updated_fail)}, error: #{e.message}" }
  end

  def delete_profile
    destroy!
    { message: I18n.t(:profile_deleted) }
  rescue StandardError => e
    { message: "#{I18n.t(:profile_deleted_fail)}, error: #{e.message}" }
  end

  def update_user(params, current_user)
    user_params = {}

    raise ApiExceptionModule::InsufficientPrivileges, I18n.t(:cannot_take_following_action) if admin_or_manager? && current_user.manager?

    if ROLES[params[:new_role_id]&.to_sym].present?
      new_role_id = ROLES[params[:new_role_id]&.to_sym] || ROLES[:regular_user]
      cannot_take_action = [ROLES[:admin], ROLES[:manager]].include?(new_role_id) && !current_user.admin?
      raise ApiExceptionModule::InsufficientPrivileges, I18n.t(:cannot_take_following_action) if cannot_take_action

      user_params[:role_id] = new_role_id
    end

    user_params[:email] = params[:new_email] if params[:new_email].present?
    user_params[:name] = params[:new_name] if params[:new_name].present?
    update!(user_params)

    { id: id, name: name, email: email, role: ROLE_NAMES[role_id.to_s] }
  rescue StandardError => e
    { message: "#{I18n.t(:failed_to_update_user)}, error: #{e.message}" }
  end

  def delete_user(current_user)
    raise ApiExceptionModule::InsufficientPrivileges, I18n.t(:cannot_take_following_action) if admin_or_manager? && current_user.manager?

    destroy!
    { message: I18n.t(:profile_deleted) }
  rescue StandardError => e
    { message: "#{I18n.t(:failed_to_delete_user)}, error: #{e.message}" }
  end

  def self.fetch_users(role, current_user, page)
    page = page.to_i.positive? ? page : 1
    role = ROLE_FILTERS.include?(role) ? role.to_sym : :regular_user

    raise ApiExceptionModule::InsufficientPrivileges, I18n.t(:cannot_take_following_action) if current_user.manager? && role != :regular_user

    if role == :all
      users = all
    else
      role_id = ROLES[role]
      users = User.where(role_id: role_id)
    end
    users = users.paginate(page: page, per_page: PER_PAGE)

    pagination_dict = { next_page: users.next_page,
                        current_page: users.current_page,
                        per_page: users.per_page,
                        total_entries: users.total_entries }

    users = users.map { |user| { id: user.id, name: user.name, role: ROLE_NAMES[user.role_id.to_s], email: user.email } }

    [users, pagination_dict]
  end

  def self.add_user(params, current_user)
    new_role_id = ROLES[params[:role_id]&.to_sym] || ROLES[:regular_user]
    cannot_take_action = [ROLES[:admin], ROLES[:manager]].include?(new_role_id) && !current_user.admin?

    raise ApiExceptionModule::InsufficientPrivileges, I18n.t(:cannot_take_following_action) if cannot_take_action

    params[:role_id] = new_role_id

    user = User.create!(params)

    { id: user.id, name: user.name, email: user.email, role: ROLE_NAMES[user.role_id.to_s] }
  rescue StandardError => e
    { message: "#{I18n.t(:failed_to_add_user)}, error: #{e.message}" }
  end

  def admin?
    role_id == ROLES[:admin]
  end

  def manager?
    role_id == ROLES[:manager]
  end

  def regular_user?
    role_id == ROLES[:regular_user]
  end

  def admin_or_manager?
    admin? || manager?
  end

  def admins
    User.where(role_id: ROLES[:admin])
  end

  def managers
    User.where(role_id: ROLES[:manager])
  end

  def regular_users
    User.where(role_id: ROLES[:regular_user])
  end
end
