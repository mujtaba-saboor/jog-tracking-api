# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JoggingEvent, type: :model do
  it { should validate_presence_of(:location) }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:time) }
  it { should validate_presence_of(:distance) }
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:time) }
  it { should validate_numericality_of(:distance) }
end
