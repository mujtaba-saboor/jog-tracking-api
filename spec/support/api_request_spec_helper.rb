# frozen_string_literal: true

# ApiRequestSpecHelper helper methods for spec
module ApiRequestSpecHelper
  def parse_json
    JSON.parse(response.body)
  end
end
