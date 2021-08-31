# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password_digest) }
  it { should validate_presence_of(:role_id) }

  it 'should remove jogging events if user is destroyed' do
    user = create(:user)
    user_id = user.id
    VCR.use_cassette('jogging_event_weather_1') do
      user.jogging_events.create!(location: 'Lahore', date: Time.zone.parse('1-8-2021'), time: 10, distance: 100)
    end
    user.destroy
    expect(JoggingEvent.find_by(user_id: user_id)).to eql(nil)
  end

  it 'should allow only 3 roles' do
    user = build(:user)
    user.role_id = 4
    expect(user.save).to be(false)
  end

  it 'should allow only 3 roles' do
    user = build(:user)
    user.role_id = 2
    expect(user.save).to be(true)
  end

  it 'should allow only 3 roles' do
    user = build(:user)
    user.role_id = 1
    expect(user.save).to be(true)
  end

  it 'should allow only 3 roles' do
    user = build(:user)
    user.role_id = 3
    expect(user.save).to be(true)
  end
end
