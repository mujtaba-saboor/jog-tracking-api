# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiRequestAuthorize do
  before :all do
    @test_user = build(:user)
    @test_user.email = 'authorize@gmail.com'
    @test_user.save
    @header = { 'HTTP_TOKEN' => valid_token_generator(@test_user.id) }
    @valid_request = ApiRequestAuthorize.new(@header)
    @invalid_request = ApiRequestAuthorize.new({})
  end

  describe 'Valid Authorize Api Request' do
    context 'valid request' do
      it 'should return a user object' do
        response = @valid_request.authorize
        expect(response[:user]).to eq(@test_user)
      end
    end
  end

  describe 'Invalid Authorize Api Request' do
    context 'api token present but expired' do
      before :all do
        @header = { 'HTTP_TOKEN' => expired_token_generator(@test_user.id) }
        @valid_request = ApiRequestAuthorize.new(@header)
      end

      it 'gives InvalidAuthToken error for expired token' do
        expect { @valid_request.authorize }.to raise_error(ApiExceptionModule::InvalidAuthToken, /#{I18n.t(:invalid_credentials)}/)
      end
    end

    context 'missing api token case' do
      it 'gives MissingAuthToken error for no token' do
        expect { @invalid_request.authorize }.to raise_error(ApiExceptionModule::MissingAuthToken, I18n.t(:missing_token))
      end
    end

    context 'api token present but for invalid user' do
      before :all do
        @invalid_request = ApiRequestAuthorize.new('HTTP_TOKEN' => valid_token_generator(101))
      end
 
      it 'gives InvalidAuthToken error for invalid user token' do
        expect { @invalid_request.authorize }.to raise_error(ApiExceptionModule::InvalidAuthToken, /#{I18n.t(:invalid_token)}/)
      end
    end

    context 'api token present but invalid' do
      before :all do
        @header = { 'HTTP_TOKEN' => 'Random_invalid_token' }
        @invalid_request = ApiRequestAuthorize.new(@header)
      end

      it 'gives InvalidAuthToken error for bogus token' do
        expect { @invalid_request.authorize }.to raise_error(ApiExceptionModule::InvalidAuthToken, /#{I18n.t(:invalid_credentials)}/)
      end
    end
  end
end
