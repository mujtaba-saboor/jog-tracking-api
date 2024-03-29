# frozen_string_literal: true

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
  c.default_cassette_options = {
    match_requests_on: [:method, VCR.request_matchers.uri_without_params(:key, :date)]
  }
end
