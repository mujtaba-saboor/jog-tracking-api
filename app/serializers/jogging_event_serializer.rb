# frozen_string_literal: true

# tracks jogging serializer
class JoggingEventSerializer < ActiveModel::Serializer
  attributes :id, :date, :location, :distance, :time, :weather_condition

  def date
    object.date.to_s(:long)
  end

  def time
    "#{object.time} #{'Minute'.pluralize(object.time)}"
  end

  def distance
    "#{object.distance} #{'KM'.pluralize(object.distance)}"
  end
end
