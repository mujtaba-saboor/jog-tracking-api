# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    # admin and manager can CRUD users
    can %i[add_user show index destroy update], User if user.admin_or_manager?

    # admin can CRUD jogging_events
    can %i[add_event update destroy_event], JoggingEvent if user.admin?

    # Everyone can signup
    can %i[create], User

    # Self user CRUD themselves
    can %i[delete_profile update_profile my_profile], User, email: user.email

    # Self actions on his/her own jog-events by logged in user
    can %i[create index weekly_report destroy], JoggingEvent, user_id: user.id
  end
end
