# frozen_string_literal: true

class Api::V1::ErrorsController < ApplicationController

  def error_four_zero_four
    raise ActiveRecord::RecordNotFound, I18n.t(:not_found, record: I18n.t(:resource_label))
  end
end
