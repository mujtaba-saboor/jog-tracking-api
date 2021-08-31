# frozen_string_literal: true

# ApiReponse contains method to format API reponse
module ApiResponse
  extend ActiveSupport::Concern

  def format_json_response(object, status = :ok)
    render json: object, status: status
  end
end
