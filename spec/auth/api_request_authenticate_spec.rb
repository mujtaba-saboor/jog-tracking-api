# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiRequestAuthenticate do
  before :all do
    @test_user = build(:user)
    @test_user.email = 'authenticate@gmail.com'
    @test_user.save
    @valid_request = ApiRequestAuthenticate.new(@test_user.email, @test_user.password)
    @invalid_request = ApiRequestAuthenticate.new('dummy', 'guy')
  end

  describe 'Valid Authorize Api Request' do
    context 'valid request' do
      it 'should return a user token' do
        response = @valid_request.authenticate
        user_id = JsonApiToken.decode_token(response)[:user_id]
        expect(user_id).to eq(@test_user.id)
      end
    end
  end

  describe 'Invalid Authorize Api Request' do
    context 'invalid request' do
      it 'gives InvalidAuthToken error for expired token' do
        expect { @invalid_request.authenticate }.to raise_error(ApiExceptionModule::UserAuthenticationError, /#{I18n.t(:invalid_credentials)}/)
      end
    end
  end
end
