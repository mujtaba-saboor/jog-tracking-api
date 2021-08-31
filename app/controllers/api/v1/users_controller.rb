# frozen_string_literal: true

# UsersController gets called for user signup
class Api::V1::UsersController < ApplicationController
  skip_before_action :authorize_api_request, only: :create
  load_and_authorize_resource

  # POST /api/v1/signup
  def create
    @user.save!
    user_auth_token = ApiRequestAuthenticate.new(@user.email, @user.password).authenticate
    format_json_response({ message: I18n.t(:signed_up_successfully), user_auth_token: user_auth_token }, :created)
  end

  # GET api/v1/users
  def index
    users, pagination_dict = @users.fetch_users(params[:role], @current_user, params[:page])
    render json: users, status: :ok, meta: pagination_dict
  end

  # GET api/v1/users/:id/
  def show
    format_json_response(@user.profile(@current_user), :ok)
  end

  # PUT api/v1/users/:id/
  def update
    result = @user.update_user(update_user_params, @current_user)
    format_json_response(result, :ok)
  end

  # DELETE api/v1/users/:id
  def destroy
    result = @user.delete_user(@current_user)
    format_json_response(result, :ok)
  end

  # POST /api/v1/add_user
  def add_user
    format_json_response(@users.add_user(add_user_params, @current_user))
  end

  # GET api/v1/users/my_profile
  def my_profile
    format_json_response(@current_user.profile(@current_user), :ok)
  end

  # PUT api/v1/users/update_profile
  def update_profile
    format_json_response(@current_user.update_profile(update_params, @current_user), :ok)
  end

  # DELETE api/v1/users/delete_profile
  def delete_profile
    format_json_response(@current_user.delete_profile, :ok)
  end

  private

  def user_params
    params.permit(:name, :email, :password, :password_confirmation)
  end

  def add_user_params
    params.permit(:name, :email, :password, :password_confirmation, :role_id)
  end

  def update_user_params
    params.permit(:new_name, :new_email, :new_role_id)
  end

  def update_params
    params.permit(:name, :email)
  end
end
