# frozen_string_literal: true

# tracks jogging
class JoggingEvent < ApplicationRecord
  belongs_to :user

  validates_presence_of :date, :location, :distance, :time, :user_id
  validate :valid_date_for_jog
  validates :distance, numericality: true
  validates :time, numericality: true
  before_save :fetch_weather_details
  serialize :weather_condition

  PAST_DATE_LOWER_LIMIT = '2009-01-01'
  WEATHER_API_URL = 'http://api.worldweatheronline.com/premium/v1/past-weather.ashx'
  WEATHER_API_KEY = 'ae54680e2ca44da79c082108212808'

  def valid_date_for_jog
    valid_date = date&.instance_of?(ActiveSupport::TimeWithZone)

    return true if valid_date && date < Time.zone.now && date >= Time.zone.parse(PAST_DATE_LOWER_LIMIT)

    errors.add(:base, I18n.t(:invalid_date))
    false
  end

  def self.filter_jogging_events(filter, page)
    page = page.to_i.positive? ? page : 1
    if filter.present?
      return { message: I18n.t(:invalid_filters_provided) } unless valid_parentheses?(filter)

      filter = filter.gsub(' gt ', '>').gsub(' lt ', '<').gsub(' eq ', '=').gsub(' ne ', '!=')
      events = all.where(filter)
    else
      events = all
    end
    events = events.paginate(page: page, per_page: User::PER_PAGE)

    pagination_dict = { next_page: events.next_page,
                        current_page: events.current_page,
                        per_page: events.per_page,
                        total_entries: events.total_entries }
    [events, pagination_dict]
  rescue ActiveRecord::StatementInvalid
    { message: I18n.t(:invalid_filters_provided) }
  end

  def self.valid_parentheses?(string)
    valid_parentheses = true
    string.gsub(/[^\(\)]/, '').split('').inject(0) do |index, parentheses|
      index += (parentheses == '(' ? 1 : -1)
      valid_parentheses = false if index.negative?
      index
    end.zero? && valid_parentheses
  end
    
  def self.weekly_report(year, month)
    return { message: I18n.t(:invalid_report_arguments) } if year.blank? || month.blank?

    valid_year = year.strip.to_i.between?(2009, Time.zone.now.year)
    valid_month = month.strip.to_i.between?(1, 12)

    return { message: I18n.t(:invalid_report_arguments) } if !valid_year || !valid_month

    result = {}
    date = Time.zone.parse("1-#{month}-#{year}")

    monthly_events = all.where(date: [date..(date + 1.month)])
    monthly_events_grouped = monthly_events.group_by { |monthly_event| monthly_event.date.beginning_of_week }.sort_by { |k, _v| k }.to_h

    monthly_events_grouped.each do |week, events|
      weekly_hour = events.inject(0) { |sum, event| sum + event.time } / 60.to_f
      weekly_distance = events.inject(0) { |sum, event| sum + event.distance }
      avg_speed = weekly_distance.to_f / weekly_hour
      result["#{week.day} #{Date::MONTHNAMES[week.month].first(3)} -> #{week.end_of_week.day} #{Date::MONTHNAMES[week.end_of_week.month].first(3)}"] = "#{avg_speed.round(2)} KMh"
    end

    result
  end

  def self.add_event(jog_params, user_id)
    raise ActiveRecord::RecordNotFound, I18n.t(:invalid_user_id_provided) if User.find_by(id: user_id).blank?

    event = all.create!(jog_params.merge(user_id: user_id))

    { message: I18n.t(:event_added), id: event.id }
  rescue StandardError => e
    { message: "#{I18n.t(:failed_to_add_jog_event)}, error: #{e.message}" }
  end

  def fetch_weather_details
    query_list = { format: 'json', key: WEATHER_API_KEY, q: location, date: date.strftime('%Y-%m-%d') }
    response = HTTParty.get(WEATHER_API_URL, query: query_list)

    if response.dig('data', 'error').present?
      errors.add(:base, response.dig('data', 'error')[0]['msg'])
      raise ActiveRecord::RecordInvalid, self

    end

    time_events = response.dig('data', 'weather')[0]['hourly'].map { |object| object['time'].to_i / 100 }
    hour = (closest_time(time_events) * 100).to_s
    self.weather_condition = response.dig('data', 'weather')[0]['hourly'].detect { |object| object['time'] == hour }
  end

  def update_event(param)
    update!(param)
    { message: I18n.t(:event_updated), id: id }
  rescue StandardError => e
    { message: "#{I18n.t(:failed_to_update_user)}, error: #{e.message}" }
  end

  def closest_time(time_events)
    target = date.hour
    time_events.min_by { |time_event| time_event <= target ? [0, target - time_event] : [1, time_event - target] }
  end
end
