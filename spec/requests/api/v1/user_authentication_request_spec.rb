# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::UserAuthentications', type: :request do
  describe 'Login Flow of User' do
    before :all do
      @test_user = build(:user)
      @test_user.email = 'userauthenticate@gmail.com'
      @test_user.save
      @header = { 'Content-Type' => 'application/json' }
      @valid_credentials = { email: @test_user.email, password: @test_user.password }
      @invalid_credentials = { email: Faker::Internet.email, password: Faker::Internet.password }
    end

    context 'user passes valid credentials' do
      it 'returns an authentication token' do
        post '/api/v1/login', params: @valid_credentials, headers: @headers
        expect(parse_json['user_auth_token']).not_to be_nil
      end
    end

    context 'user passes invalid credentials' do
      it 'returns a failure message' do
        post '/api/v1/login', params: @invalid_credentials, headers: @headers
        expect(parse_json['message']).to match(/#{I18n.t(:invalid_credentials)}/)
      end
    end
  end
end
