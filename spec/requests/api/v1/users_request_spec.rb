# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  before :all do
    User.all.destroy_all
  end

  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:test_user) { build_sign_up_user }
  let(:admin_user) { create_admin }
  let(:a_headers) { valid_headers(admin_user) }
  let(:regular_user) { create_regular_user }
  let(:r_headers) { valid_headers(regular_user) }
  let(:manager_user) { create_manager }
  let(:m_headers) { valid_headers(manager_user) }
  let(:valid_user_params) { attributes_for(:user, password_confirmation: test_user.password, email: test_user.email) }

  describe 'Signup Flow of User' do
    context 'invalid user parameters' do
      before { post '/api/v1/signup', params: {}, headers: headers }

      it 'signup fails - status code' do
        expect(response).to have_http_status(422)
      end

      it 'signup fails - message' do
        expect(parse_json['message']).to match(/Validation failed/)
      end
    end

    context 'valid user parameters' do
      before { post '/api/v1/signup', params: valid_user_params.to_json, headers: headers }

      it 'signed up successfully - status code' do
        expect(response).to have_http_status(201)
      end

      it 'signed up successfully - message' do
        expect(parse_json['message']).to match(/#{I18n.t(:signed_up_successfully)}/)
      end

      it 'signed up successfully - returns token' do
        expect(parse_json['user_auth_token']).not_to be_nil
      end
    end
  end

  describe 'Fetch Users flow' do
    context 'with no users' do
      before { get '/api/v1/users', headers: a_headers }

      it 'valid status code' do
        expect(response).to have_http_status(200)
      end

      it 'empty response as no users' do
        expect(parse_json['users'].size).to eq(0)
      end
    end

    context 'with regular users' do
      before :all do
        add_dummy_users(:regular_user)
      end

      it 'response with users regular' do
        get '/api/v1/users', headers: a_headers
        expect(parse_json['users'].size).to eq(10)
        uniq_roles = parse_json['users'].map { |u| u['role'] }.uniq
        expect(uniq_roles.size).to eq(1)
        expect(uniq_roles.first).to eq('Regular User')
      end
    end

    context 'with admin users' do
      before :all do
        add_dummy_users(:admin)
      end

      it 'response with users admin' do
        get '/api/v1/users', headers: a_headers, params: { role: 'admin' }
        expect(parse_json['users'].size).to eq(10)
        uniq_roles = parse_json['users'].map { |u| u['role'] }.uniq
        expect(uniq_roles.size).to eq(1)
        expect(uniq_roles.first).to eq('Administrator')
      end
    end

    context 'with manager users' do
      before :all do
        add_dummy_users(:manager)
      end

      it 'response with users manager' do
        get '/api/v1/users', headers: a_headers, params: { role: 'manager' }
        expect(parse_json['users'].size).to eq(10)
        uniq_roles = parse_json['users'].map { |u| u['role'] }.uniq
        expect(uniq_roles.size).to eq(1)
        expect(uniq_roles.first).to eq('Manager')
      end
    end

    context 'all users' do
      it 'response with users' do
        get '/api/v1/users', headers: a_headers, params: { role: 'all' }
        expect(parse_json['users'].size).to eq(10)
        expect(parse_json['meta']['next_page']).to eq(2)
        expect(parse_json['meta']['current_page']).to eq(1)
        expect(parse_json['meta']['total_entries']).to eq(31)
      end

      it 'response with users - 2' do
        get '/api/v1/users', headers: a_headers, params: { role: 'all', page: 2 }
        expect(parse_json['users'].size).to eq(10)
        expect(parse_json['meta']['next_page']).to eq(3)
        expect(parse_json['meta']['current_page']).to eq(2)
        expect(parse_json['meta']['total_entries']).to eq(31)
      end

      it 'response with users - 3' do
        get '/api/v1/users', headers: a_headers, params: { role: 'all', page: 3 }
        expect(parse_json['users'].size).to eq(10)
        expect(parse_json['meta']['next_page']).to eq(4)
        expect(parse_json['meta']['current_page']).to eq(3)
        expect(parse_json['meta']['total_entries']).to eq(31)
      end

      it 'regular users cannot fetch' do
        get '/api/v1/users', headers: r_headers
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
      end

      it 'manager users can only fetch regular users' do
        get '/api/v1/users', headers: m_headers, params: { role: 'regular_user' }
        expect(parse_json['users'].size).to eq(10)
        uniq_roles = parse_json['users'].map { |u| u['role'] }.uniq
        expect(uniq_roles.size).to eq(1)
        expect(uniq_roles.first).to eq('Regular User')
        expect(parse_json['meta']['total_entries']).to eq(10)
      end

      it 'manager users can only fetch regular users - not authorized' do
        get '/api/v1/users', headers: m_headers, params: { role: 'admin' }
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
      end

      it 'manager users can only fetch regular users - not authorized' do
        get '/api/v1/users', headers: m_headers, params: { role: 'manager' }
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
      end
    end
  end

  describe 'Show Users flow' do
    context 'get show' do
      it 'regular user cannot' do
        get "/api/v1/users/#{regular_user.id}", headers: r_headers
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
      end

      it 'manager can only for regular user' do
        get "/api/v1/users/#{regular_user.id}", headers: m_headers
        expect(parse_json['profile']['id']).to eq(regular_user.id)
        manager_user_id = User.where(role_id: 2).where.not(id: manager_user.id).first.id
        get "/api/v1/users/#{manager_user_id}", headers: m_headers
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
        get "/api/v1/users/#{admin_user.id}", headers: m_headers
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
      end

      it 'admin can only for all user' do
        get "/api/v1/users/#{regular_user.id}", headers: a_headers
        expect(parse_json['profile']['id']).to eq(regular_user.id)
        get "/api/v1/users/#{manager_user.id}", headers: a_headers
        expect(parse_json['profile']['id']).to eq(manager_user.id)
        get "/api/v1/users/#{admin_user.id}", headers: a_headers
        expect(parse_json['profile']['id']).to eq(admin_user.id)
      end
    end
  end

  describe 'Update Users flow' do
    context 'put update' do
      it 'regular user cannot' do
        put "/api/v1/users/#{regular_user.id}", headers: r_headers
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
      end

      it 'manager can only for regular user' do
        put "/api/v1/users/#{regular_user.id}", headers: m_headers, params: { new_name: 'new name' }.to_json
        expect(regular_user.reload.name).to eq('new name')
        put "/api/v1/users/#{manager_user.id}", headers: m_headers
        expect(parse_json['message']).to eq('Failed to update user, error: You are not authorized to access this page.')
        put "/api/v1/users/#{admin_user.id}", headers: m_headers
        expect(parse_json['message']).to eq('Failed to update user, error: You are not authorized to access this page.')
      end

      it 'admin can for all user' do
        put "/api/v1/users/#{regular_user.id}", headers: a_headers, params: { new_name: 'new name' }.to_json
        expect(regular_user.reload.name).to eq('new name')
        put "/api/v1/users/#{manager_user.id}", headers: a_headers, params: { new_name: 'new name' }.to_json
        expect(manager_user.reload.name).to eq('new name')
        put "/api/v1/users/#{admin_user.id}", headers: a_headers, params: { new_name: 'new name' }.to_json
        expect(admin_user.reload.name).to eq('new name')
      end
    end
  end

  describe 'Delete Users flow' do
    context 'delete' do
      it 'regular user cannot' do
        delete "/api/v1/users/#{regular_user.id}", headers: r_headers
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
      end

      it 'manager can only for regular user' do
        regular_user_to_del = User.where(role_id: 3).where.not(id: regular_user.id).first.id
        delete "/api/v1/users/#{regular_user_to_del}", headers: m_headers
        expect(User.find_by(id: regular_user_to_del)).to eq(nil)
        delete "/api/v1/users/#{manager_user.id}", headers: m_headers
        expect(parse_json['message']).to eq('Failed to delete user, error: You are not authorized to access this page.')
        delete "/api/v1/users/#{admin_user.id}", headers: m_headers
        expect(parse_json['message']).to eq('Failed to delete user, error: You are not authorized to access this page.')
      end

      it 'admin can for all user' do
        regular_user_to_del = User.where(role_id: 3).where.not(id: regular_user.id).first.id
        delete "/api/v1/users/#{regular_user_to_del}", headers: a_headers, params: { new_name: 'new name' }.to_json
        expect(User.find_by(id: regular_user_to_del)).to eq(nil)
        manager_user_to_del = User.where(role_id: 2).where.not(id: manager_user.id).first.id
        delete "/api/v1/users/#{manager_user_to_del}", headers: a_headers, params: { new_name: 'new name' }.to_json
        expect(User.find_by(id: manager_user_to_del)).to eq(nil)
        admin_user_to_del = User.where(role_id: 1).where.not(id: admin_user.id).first.id
        delete "/api/v1/users/#{admin_user_to_del}", headers: a_headers, params: { new_name: 'new name' }.to_json
        expect(User.find_by(id: admin_user_to_del)).to eq(nil)
      end
    end
  end

  describe 'Add Users flow' do
    context 'post' do
      it 'regular user cannot' do
        post '/api/v1/users/add_user', headers: r_headers
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
      end

      it 'manager can only for regular user' do
        params = { name: 'regular', email: 'regular@ok.com', password: 'regular' }
        post '/api/v1/users/add_user', headers: m_headers, params: params.to_json
        expect(parse_json['email']).to eq(params[:email])
        expect(parse_json['role']).to eq('Regular User')

        params = { name: 'regular', email: 'regular1@ok.com', password: 'regular', role_id: 'regular_user' }
        post '/api/v1/users/add_user', headers: m_headers, params: params.to_json
        expect(parse_json['email']).to eq(params[:email])
        expect(parse_json['role']).to eq('Regular User')

        params = { name: 'regular', email: 'regular1@ok.com', password: 'regular', role_id: 'manager' }
        post '/api/v1/users/add_user', headers: m_headers, params: params.to_json
        expect(parse_json['message']).to eq('Failed to add user, error: You are not authorized to access this page.')

        params = { name: 'regular', email: 'regular1@ok.com', password: 'regular', role_id: 'admin' }
        post '/api/v1/users/add_user', headers: m_headers, params: params.to_json
        expect(parse_json['message']).to eq('Failed to add user, error: You are not authorized to access this page.')
      end

      it 'admin can for all user' do
        params = { name: 'regular', email: 'regular1@ok.com', password: 'regular', role_id: 'regular_user' }
        post '/api/v1/users/add_user', headers: a_headers, params: params.to_json
        expect(parse_json['email']).to eq(params[:email])
        expect(parse_json['role']).to eq('Regular User')

        params = { name: 'regular', email: 'manager1@ok.com', password: 'regular', role_id: 'manager' }
        post '/api/v1/users/add_user', headers: a_headers, params: params.to_json
        expect(parse_json['email']).to eq(params[:email])
        expect(parse_json['role']).to eq('Manager')

        params = { name: 'regular', email: 'admin1@ok.com', password: 'regular', role_id: 'admin' }
        post '/api/v1/users/add_user', headers: a_headers, params: params.to_json
        expect(parse_json['email']).to eq(params[:email])
        expect(parse_json['role']).to eq('Administrator')
      end
    end
  end

  describe 'My Profile flows' do
    context 'view flows' do
      it 'all users can view their profile - r' do
        get '/api/v1/users/my_profile', headers: r_headers
        expect(parse_json['profile']['id']).to eq(regular_user.id)
      end

      it 'all users can view their profile - m' do
        get '/api/v1/users/my_profile', headers: m_headers
        expect(parse_json['profile']['id']).to eq(manager_user.id)
      end

      it 'all users can view their profile - a' do
        get '/api/v1/users/my_profile', headers: a_headers
        expect(parse_json['profile']['id']).to eq(admin_user.id)
      end
    end

    context 'update flows' do
      it 'all users can update their profile - r' do
        put '/api/v1/users/update_profile', headers: r_headers, params: { name: 'newest' }.to_json
        expect(parse_json['profile']['id']).to eq(regular_user.id)
        expect(parse_json['profile']['name']).to eq('newest')
      end

      it 'all users can update their profile - m' do
        put '/api/v1/users/update_profile', headers: m_headers, params: { name: 'newest' }.to_json
        expect(parse_json['profile']['id']).to eq(manager_user.id)
        expect(parse_json['profile']['name']).to eq('newest')
      end

      it 'all users can update their profile - a' do
        put '/api/v1/users/update_profile', headers: a_headers, params: { name: 'newest' }.to_json
        expect(parse_json['profile']['id']).to eq(admin_user.id)
        expect(parse_json['profile']['name']).to eq('newest')
      end
    end

    context 'delete flows' do
      it 'all users can delete their profile - r' do
        regular_user_to_del = User.where(role_id: 3).where.not(id: regular_user.id).first
        id = regular_user_to_del.id
        temp_headers = valid_headers(regular_user_to_del)
        delete '/api/v1/users/delete_profile', headers: temp_headers
        expect(User.find_by(id: id)).to eq(nil)
      end

      it 'all users can delete their profile - m' do
        manager_user_to_del = User.where(role_id: 2).where.not(id: manager_user.id).first
        id = manager_user_to_del.id
        temp_headers = valid_headers(manager_user_to_del)
        delete '/api/v1/users/delete_profile', headers: temp_headers
        expect(User.find_by(id: id)).to eq(nil)
      end

      it 'all users can delete their profile - a' do
        admin_user_to_del = User.where(role_id: 1).where.not(id: admin_user.id).first
        id = admin_user_to_del.id
        temp_headers = valid_headers(admin_user_to_del)
        delete '/api/v1/users/delete_profile', headers: temp_headers
        expect(User.find_by(id: id)).to eq(nil)
      end
    end
  end

  def add_dummy_users(role)
    $counter ||= 0
    role_id = User::ROLES[role]
    10.times do
      user = build(:user)
      user.email = "#{user.email}#{$counter}"
      user.role_id = role_id
      user.save
      $counter += 1
    end
  end
end
