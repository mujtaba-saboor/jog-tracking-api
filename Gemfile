# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

gem 'active_model_serializers', '~> 0.8.0'
gem 'bcrypt', '~> 3.1.7'
gem 'cancancan'
gem 'httparty'
gem 'jwt'
gem 'mysql2', '=0.5.3'
gem 'puma', '~> 5.0'
gem 'rails', '~> 6.1.4', '>= 6.1.4.1'
gem 'will_paginate', '=3.3.0'

group :development, :test do
  gem 'pry', '=0.13.1'
  gem 'rspec-rails', '=4.0.1'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
end

group :test do
  gem 'database_cleaner', '=2.0.1'
  gem 'factory_bot_rails', '=6.1.0'
  gem 'faker', '=2.17.0'
  gem 'shoulda-matchers', '=4.5.1'
  gem 'vcr'
  gem 'webmock'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
