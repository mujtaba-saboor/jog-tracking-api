# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { 'dummy@user1.com' }
    password { 'dummypw' }
  end
end
