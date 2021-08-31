# frozen_string_literal: true

# JoggingEventsController gets called for recording jog events
class Api::V1::JoggingEventsController < ApplicationController
  load_and_authorize_resource

  # POST /api/v1/add_jog
  def create
    @jogging_event.save!
    format_json_response({ message: I18n.t(:event_added), id: @jogging_event.id }, :created)
  end

  # POST /api/v1/jogging_events
  def index
    jogging_events, pagination_dict = @jogging_events.filter_jogging_events(params[:filter], params[:page])
    render json: jogging_events, status: :ok, meta: pagination_dict
  end

  # DELETE /api/v1/jogging_events/:id
  def destroy
    @jogging_event.destroy!
    format_json_response({ message: I18n.t(:event_deleted) }, :ok)
  end

  # POST /api/v1/jogging_events
  def add_event
    result = @jogging_events.add_event(jogging_event_params, params[:user_id])
    format_json_response(result, :ok)
  end

  # PUT /api/v1/jogging_events/:id
  def update
    result = @jogging_event.update_event(update_event_params)
    format_json_response(result, :ok)
  end

  # DELETE /api/v1/jogging_events/:id/destroy_event
  def destroy_event
    destroy
  end

  # GET /api/v1/jogging_events/weekly_report
  def weekly_report
    weekly_report = @jogging_events.weekly_report(params[:year], params[:month])
    format_json_response(weekly_report, :ok)
  end

  private

  def jogging_event_params
    params.permit(:date, :distance, :location, :time)
  end

  def update_event_params
    params.permit(:date, :distance, :location, :time)
  end
end
