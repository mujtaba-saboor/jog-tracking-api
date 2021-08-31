require 'rails_helper'

RSpec.describe "Api::V1::JoggingEvents", type: :request do
  before :all do
    @admin_user = create_admin_jog
    @a_headers = valid_headers(@admin_user)
    @regular_user = create_regular_user_jog
    @r_headers = valid_headers(@regular_user)
    @manager_user = create_manager_jog
    @m_headers = valid_headers(@manager_user)
    create_user_events(@r_headers, 'regular_user')
    create_user_events(@m_headers, 'manager')
    create_user_events(@a_headers, 'admin')
  end

  describe 'Create jogging events' do
    context 'create' do
      it 'creates jogging event - valid params - regular' do
        params = { date: Time.zone.parse('1-8-2021'), distance: 20, location: 'Lahore', time: 40 }
        VCR.use_cassette('jogging_event_weather_1') do
          post '/api/v1/jogging_events', headers: @r_headers, params: params.to_json
        end
        expect(parse_json['message']).to eq('Jog event added successfully!')
      end

      it 'creates jogging event - valid params - manager' do
        params = { date: Time.zone.parse('1-8-2021'), distance: 20, location: 'Lahore', time: 40 }
        VCR.use_cassette('jogging_event_weather_1') do
          post '/api/v1/jogging_events', headers: @m_headers, params: params.to_json
        end
        expect(parse_json['message']).to eq('Jog event added successfully!')
      end

      it 'creates jogging event - valid params - admin' do
        params = { date: Time.zone.parse('1-8-2021'), distance: 20, location: 'Lahore', time: 40 }
        VCR.use_cassette('jogging_event_weather_1') do
          post '/api/v1/jogging_events', headers: @a_headers, params: params.to_json
        end
        expect(parse_json['message']).to eq('Jog event added successfully!')
      end

      it 'creates jogging event - invalid location' do
        params = { date: Time.zone.parse('1-8-2021'), distance: 20, location: 'll', time: 40 }
        VCR.use_cassette('jogging_event_weather_2') do
          post '/api/v1/jogging_events', headers: @r_headers, params: params.to_json
        end
        expect(parse_json['message']).to eq('Validation failed: Unable to find any matching weather location to the query submitted!')
      end

      it 'creates jogging event - invalid date' do
        params = { date: Time.zone.parse('1-1-2008'), distance: 20, location: 'll', time: 40 }
        VCR.use_cassette('jogging_event_weather_2') do
          post '/api/v1/jogging_events', headers: @r_headers, params: params.to_json
        end
        expect(parse_json['message']).to eq('Validation failed: Invalid date provided')
      end
    end
  end

  describe 'Fetch jogging events' do
    context 'get - regular' do
      it 'fetches jogging event - regular - 1' do
        get '/api/v1/jogging_events', headers: @r_headers
        expect(parse_json['meta']['total_entries']).to eq(30)
        ids = parse_json['jogging_events'].map { |jog| jog['id'] }.uniq
        uniq_id = JoggingEvent.where(id: ids).pluck(:user_id).uniq
        expect(uniq_id.size).to eq(1)
        expect(uniq_id.first).to eq(@regular_user.id)
        expect(parse_json['meta']['next_page']).to eq(2)
      end

      it 'fetches jogging event - regular - 2' do
        get '/api/v1/jogging_events', headers: @r_headers, params: { page: 2 }
        expect(parse_json['meta']['total_entries']).to eq(30)
        ids = parse_json['jogging_events'].map { |jog| jog['id'] }.uniq
        uniq_id = JoggingEvent.where(id: ids).pluck(:user_id).uniq
        expect(uniq_id.size).to eq(1)
        expect(uniq_id.first).to eq(@regular_user.id)
        expect(parse_json['meta']['next_page']).to eq(3)
      end

      it 'fetches jogging event - regular - 3' do
        get '/api/v1/jogging_events', headers: @r_headers, params: { page: 3 }
        expect(parse_json['meta']['total_entries']).to eq(30)
        ids = parse_json['jogging_events'].map { |jog| jog['id'] }.uniq
        uniq_id = JoggingEvent.where(id: ids).pluck(:user_id).uniq
        expect(uniq_id.size).to eq(1)
        expect(uniq_id.first).to eq(@regular_user.id)
        expect(parse_json['meta']['next_page']).to eq(nil)
      end
    end

    context 'get - manager' do
      it 'fetches jogging event - manager - 1' do
        get '/api/v1/jogging_events', headers: @m_headers
        expect(parse_json['meta']['total_entries']).to eq(30)
        ids = parse_json['jogging_events'].map { |jog| jog['id'] }.uniq
        uniq_id = JoggingEvent.where(id: ids).pluck(:user_id).uniq
        expect(uniq_id.size).to eq(1)
        expect(uniq_id.first).to eq(@manager_user.id)
        expect(parse_json['meta']['next_page']).to eq(2)
      end

      it 'fetches jogging event - manager - 2' do
        get '/api/v1/jogging_events', headers: @m_headers, params: { page: 2 }
        expect(parse_json['meta']['total_entries']).to eq(30)
        ids = parse_json['jogging_events'].map { |jog| jog['id'] }.uniq
        uniq_id = JoggingEvent.where(id: ids).pluck(:user_id).uniq
        expect(uniq_id.size).to eq(1)
        expect(uniq_id.first).to eq(@manager_user.id)
        expect(parse_json['meta']['next_page']).to eq(3)
      end

      it 'fetches jogging event - manager - 3' do
        get '/api/v1/jogging_events', headers: @m_headers, params: { page: 3 }
        expect(parse_json['meta']['total_entries']).to eq(30)
        ids = parse_json['jogging_events'].map { |jog| jog['id'] }.uniq
        uniq_id = JoggingEvent.where(id: ids).pluck(:user_id).uniq
        expect(uniq_id.size).to eq(1)
        expect(uniq_id.first).to eq(@manager_user.id)
        expect(parse_json['meta']['next_page']).to eq(nil)
      end
    end

    context 'get - admin' do
      it 'fetches jogging event - admin - 1' do
        get '/api/v1/jogging_events', headers: @a_headers
        expect(parse_json['meta']['total_entries']).to eq(30)
        ids = parse_json['jogging_events'].map { |jog| jog['id'] }.uniq
        uniq_id = JoggingEvent.where(id: ids).pluck(:user_id).uniq
        expect(uniq_id.size).to eq(1)
        expect(uniq_id.first).to eq(@admin_user.id)
        expect(parse_json['meta']['next_page']).to eq(2)
      end

      it 'fetches jogging event - admin - 2' do
        get '/api/v1/jogging_events', headers: @a_headers, params: { page: 2 }
        expect(parse_json['meta']['total_entries']).to eq(30)
        ids = parse_json['jogging_events'].map { |jog| jog['id'] }.uniq
        uniq_id = JoggingEvent.where(id: ids).pluck(:user_id).uniq
        expect(uniq_id.size).to eq(1)
        expect(uniq_id.first).to eq(@admin_user.id)
        expect(parse_json['meta']['next_page']).to eq(3)
      end

      it 'fetches jogging event - admin - 3' do
        get '/api/v1/jogging_events', headers: @a_headers, params: { page: 3 }
        expect(parse_json['meta']['total_entries']).to eq(30)
        ids = parse_json['jogging_events'].map { |jog| jog['id'] }.uniq
        uniq_id = JoggingEvent.where(id: ids).pluck(:user_id).uniq
        expect(uniq_id.size).to eq(1)
        expect(uniq_id.first).to eq(@admin_user.id)
        expect(parse_json['meta']['next_page']).to eq(nil)
      end
    end

    context 'get - with filters' do
      it 'test filters - eq' do
        params = { filter: "location eq 'Lahore'" }
        get '/api/v1/jogging_events', headers: @a_headers, params: params
        expect(parse_json['meta']['total_entries']).to eq(30)
      end

      it 'test filters - ne' do
        params = { filter: "location ne 'Lahore'" }
        get '/api/v1/jogging_events', headers: @a_headers, params: params
        expect(parse_json['meta']['total_entries']).to eq(0)
      end

      it 'test filters - gt' do
        params = { filter: "date gt '2021-8-12'" }
        get '/api/v1/jogging_events', headers: @a_headers, params: params
        expect(parse_json['meta']['total_entries']).to eq(18)
      end

      it 'test filters - lt' do
        params = { filter: "date lt '2021-8-12'" }
        get '/api/v1/jogging_events', headers: @a_headers, params: params
        expect(parse_json['meta']['total_entries']).to eq(11)
      end

      it 'test filters - combination1' do
        params = { filter: "(date lt '2021-8-12') AND date gt '2021-8-1'" }
        get '/api/v1/jogging_events', headers: @a_headers, params: params
        expect(parse_json['meta']['total_entries']).to eq(10)
      end

      it 'test filters - combination2' do
        params = { filter: "(date lt '2021-8-12') AND date gt '2021-8-1' OR (location eq 'Lahore')" }
        get '/api/v1/jogging_events', headers: @a_headers, params: params
        expect(parse_json['meta']['total_entries']).to eq(30)
      end

      it 'test filters - combination3' do
        params = { filter: "(date lt '2021-8-12') AND date gt '2021-8-1' OR (location eq 'Lahore' AND (date eq '2021-8-14'))" }
        get '/api/v1/jogging_events', headers: @a_headers, params: params
        expect(parse_json['meta']['total_entries']).to eq(11)
      end

      it 'test filters - invalid fitlers' do
        params = { filter: '(' }
        get '/api/v1/jogging_events', headers: @a_headers, params: params
        expect(parse_json['message']).to eq('Invalid Filters Provided')
      end
    end
  end

  describe 'Delete jogging events' do
    context 'delete - regular' do
      it 'deletes jogging event - regular' do
        jog_event = JoggingEvent.find_by(user_id: @regular_user.id)
        id = jog_event.id
        delete "/api/v1/jogging_events/#{id}", headers: @r_headers
        expect(parse_json['message']).to eq('Jog event deleted successfully')
        expect(JoggingEvent.find_by(id: id)).to eq(nil)
      end
    end

    context 'delete - manager' do
      it 'deletes jogging event - manager' do
        jog_event = JoggingEvent.find_by(user_id: @manager_user.id)
        id = jog_event.id
        delete "/api/v1/jogging_events/#{id}", headers: @m_headers
        expect(parse_json['message']).to eq('Jog event deleted successfully')
        expect(JoggingEvent.find_by(id: id)).to eq(nil)
      end
    end

    context 'delete - admin' do
      it 'deletes jogging event - admin' do
        jog_event = JoggingEvent.find_by(user_id: @admin_user.id)
        id = jog_event.id
        delete "/api/v1/jogging_events/#{id}", headers: @a_headers
        expect(parse_json['message']).to eq('Jog event deleted successfully')
        expect(JoggingEvent.find_by(id: id)).to eq(nil)
      end
    end

    context 'deleting someone elses event not allowed' do
      it 'not deletes jogging event - admin effort' do
        jog_event = JoggingEvent.find_by(user_id: @regular_user.id)
        id = jog_event.id
        delete "/api/v1/jogging_events/#{id}", headers: @a_headers
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
        expect(JoggingEvent.find_by(id: id).present?).to eq(true)
        jog_event = JoggingEvent.find_by(user_id: @manager_user.id)
        id = jog_event.id
        delete "/api/v1/jogging_events/#{id}", headers: @a_headers
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
        expect(JoggingEvent.find_by(id: id).present?).to eq(true)
      end

      it 'not deletes jogging event - manager effort' do
        jog_event = JoggingEvent.find_by(user_id: @admin_user.id)
        id = jog_event.id
        delete "/api/v1/jogging_events/#{id}", headers: @m_headers
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
        expect(JoggingEvent.find_by(id: id).present?).to eq(true)
        jog_event = JoggingEvent.find_by(user_id: @regular_user.id)
        id = jog_event.id
        delete "/api/v1/jogging_events/#{id}", headers: @m_headers
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
        expect(JoggingEvent.find_by(id: id).present?).to eq(true)
      end

      it 'not deletes jogging event - regular user effort' do
        jog_event = JoggingEvent.find_by(user_id: @admin_user.id)
        id = jog_event.id
        delete "/api/v1/jogging_events/#{id}", headers: @r_headers
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
        expect(JoggingEvent.find_by(id: id).present?).to eq(true)
        jog_event = JoggingEvent.find_by(user_id: @manager_user.id)
        id = jog_event.id
        delete "/api/v1/jogging_events/#{id}", headers: @r_headers
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
        expect(JoggingEvent.find_by(id: id).present?).to eq(true)
      end
    end
  end

  describe 'Weekly report' do
    context 'fetch weekly report' do
      it 'does not fetch with no params' do
        get '/api/v1/jogging_events/weekly_report', headers: @r_headers
        expect(parse_json['message']).to eq('Invalid year or month provided')
      end

      it 'does not fetch with invalid month' do
        get '/api/v1/jogging_events/weekly_report', headers: @r_headers, params: { month: 13 }
        expect(parse_json['message']).to eq('Invalid year or month provided')
        get '/api/v1/jogging_events/weekly_report', headers: @r_headers, params: { month: 0 }
        expect(parse_json['message']).to eq('Invalid year or month provided')
      end

      it 'does not fetch with invalid year' do
        get '/api/v1/jogging_events/weekly_report', headers: @r_headers, params: { year: 13, month: 2 }
        expect(parse_json['message']).to eq('Invalid year or month provided')
        get '/api/v1/jogging_events/weekly_report', headers: @r_headers, params: { year: 2008 }
        expect(parse_json['message']).to eq('Invalid year or month provided')
      end

      it 'fetch with valid year/month' do
        get '/api/v1/jogging_events/weekly_report', headers: @r_headers, params: { year: 2021, month: 8 }
        expect(response).to have_http_status(200)
        expect(parse_json.present?).to be(true)
        august_first = Time.zone.parse('1-8-2021').beginning_of_month
        events = JoggingEvent.where(user_id: @regular_user.id, date: (august_first + 1.day)..(august_first + 7.day))
        run_time = events.inject(0) { |sum, event| sum + event.time } / 60.to_f
        weekly_distance = events.inject(0) { |sum, event| sum + event.distance }
        calc_value = weekly_distance / run_time
        expect(parse_json["#{(august_first + 1.day).day} Aug -> #{(august_first + 7.day).day} Aug"]).to eq("#{calc_value} KMh")
      end

      it 'does not fetch with invalid year' do
        get '/api/v1/jogging_events/weekly_report', headers: @r_headers, params: { year: 2021, month: 6 }
        expect(response).to have_http_status(200)
        expect(parse_json.present?).to be(false)
      end
    end
  end

  describe 'Admin CRUD events' do
    context 'admin can create all records' do
      it 'admin can add for regular user' do
        params = { date: Time.zone.parse('1-8-2021'), distance: 20, location: 'London', time: 40, user_id: @regular_user.id }
        VCR.use_cassette('add_event_admin1') do
          post '/api/v1/jogging_events/add_event', headers: @a_headers, params: params.to_json
        end
        expect(parse_json['message']).to eq('Jog event added successfully!')
        expect(@regular_user.id).to eq(JoggingEvent.find_by(id: parse_json['id']).user_id)
      end

      it 'admin can add for manager user' do
        params = { date: Time.zone.parse('1-8-2021'), distance: 20, location: 'Mumbai', time: 40, user_id: @manager_user.id }
        VCR.use_cassette('add_event_admin2') do
          post '/api/v1/jogging_events/add_event', headers: @a_headers, params: params.to_json
        end
        expect(parse_json['message']).to eq('Jog event added successfully!')
        expect(@manager_user.id).to eq(JoggingEvent.find_by(id: parse_json['id']).user_id)
      end

      it 'admin can add for admin user' do
        params = { date: Time.zone.parse('1-8-2021'), distance: 20, location: 'Paris', time: 40, user_id: @admin_user.id }
        VCR.use_cassette('add_event_admin3') do
          post '/api/v1/jogging_events/add_event', headers: @a_headers, params: params.to_json
        end
        expect(parse_json['message']).to eq('Jog event added successfully!')
        expect(@admin_user.id).to eq(JoggingEvent.find_by(id: parse_json['id']).user_id)
      end

      it 'admin can add - invalid user_id' do
        params = { date: Time.zone.parse('1-8-2021'), distance: 20, location: 'London', time: 40, user_id: 'apple' }
        post '/api/v1/jogging_events/add_event', headers: @a_headers, params: params.to_json
        expect(parse_json['message']).to eq('Failed to add jog event, error: Invalid user_id provided')
      end

      it 'managers cannot add' do
        params = { date: Time.zone.parse('1-8-2021'), distance: 20, location: 'London', time: 40 }
        post '/api/v1/jogging_events/add_event', headers: @m_headers, params: params.to_json
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
      end

      it 'regular user cannot add' do
        params = { date: Time.zone.parse('1-8-2021'), distance: 20, location: 'London', time: 40 }
        post '/api/v1/jogging_events/add_event', headers: @r_headers, params: params.to_json
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
      end
    end

    context 'admin can update all records' do
      it 'admin can put for regular user' do
        jog = @regular_user.jogging_events.first
        params = { date: Time.zone.parse('10-8-2021'), distance: 200, location: 'Nice', time: 400 }
        VCR.use_cassette('put_event_admin1') do
          put "/api/v1/jogging_events/#{jog.id}", headers: @a_headers, params: params.to_json
        end
        expect(parse_json['message']).to eq('Event updated successfully')
        jog = jog.reload
        expect(parse_json['id']).to eq(jog.id)
        expect(jog.location).to eq('Nice')
        expect(jog.distance).to eq(200)
        expect(jog.time).to eq(400)
        expect(jog.date).to eq(Time.zone.parse('10-8-2021'))
      end

      it 'admin can put for manager user' do
        jog = @manager_user.jogging_events.first
        params = { date: Time.zone.parse('10-8-2021'), distance: 200, location: 'Nice', time: 400 }
        VCR.use_cassette('put_event_admin1') do
          put "/api/v1/jogging_events/#{jog.id}", headers: @a_headers, params: params.to_json
        end
        expect(parse_json['message']).to eq('Event updated successfully')
        jog = jog.reload
        expect(parse_json['id']).to eq(jog.id)
        expect(jog.location).to eq('Nice')
        expect(jog.distance).to eq(200)
        expect(jog.time).to eq(400)
        expect(jog.date).to eq(Time.zone.parse('10-8-2021'))
      end

      it 'admin can put for admin user' do
        jog = @admin_user.jogging_events.first
        params = { date: Time.zone.parse('10-8-2021'), distance: 200, location: 'Nice', time: 400 }
        VCR.use_cassette('put_event_admin1') do
          put "/api/v1/jogging_events/#{jog.id}", headers: @a_headers, params: params.to_json
        end
        expect(parse_json['message']).to eq('Event updated successfully')
        jog = jog.reload
        expect(parse_json['id']).to eq(jog.id)
        expect(jog.location).to eq('Nice')
        expect(jog.distance).to eq(200)
        expect(jog.time).to eq(400)
        expect(jog.date).to eq(Time.zone.parse('10-8-2021'))
      end

      it 'regular user cannot put' do
        jog = @admin_user.jogging_events.first
        params = { date: Time.zone.parse('10-8-2021'), distance: 200, location: 'Nice', time: 400 }
        put "/api/v1/jogging_events/#{jog.id}", headers: @r_headers, params: params.to_json
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
      end

      it 'manager user cannot put' do
        jog = @admin_user.jogging_events.first
        params = { date: Time.zone.parse('10-8-2021'), distance: 200, location: 'Nice', time: 400 }
        put "/api/v1/jogging_events/#{jog.id}", headers: @m_headers, params: params.to_json
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
      end
    end

    context 'admin can delete all records' do
      it 'admin can delete for regular user' do
        jog = @regular_user.jogging_events.first.id
        delete "/api/v1/jogging_events/#{jog}/destroy_event", headers: @a_headers
        expect(parse_json['message']).to eq('Jog event deleted successfully')
        expect(JoggingEvent.find_by(id: jog)).to eq(nil)
      end

      it 'admin can delete for manager user' do
        jog = @manager_user.jogging_events.first.id
        delete "/api/v1/jogging_events/#{jog}/destroy_event", headers: @a_headers
        expect(parse_json['message']).to eq('Jog event deleted successfully')
        expect(JoggingEvent.find_by(id: jog)).to eq(nil)
      end

      it 'admin can delete for admin user' do
        jog = @admin_user.jogging_events.first.id
        delete "/api/v1/jogging_events/#{jog}/destroy_event", headers: @a_headers
        expect(parse_json['message']).to eq('Jog event deleted successfully')
        expect(JoggingEvent.find_by(id: jog)).to eq(nil)
      end

      it 'regular user cannot delete' do
        jog = @admin_user.jogging_events.first
        delete "/api/v1/jogging_events/#{jog.id}/destroy_event", headers: @r_headers
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
      end

      it 'manager user cannot delete' do
        jog = @admin_user.jogging_events.first
        delete "/api/v1/jogging_events/#{jog.id}/destroy_event", headers: @m_headers
        expect(parse_json['message']).to eq('You are not authorized to access this page.')
      end
    end
  end

  def create_user_events(headers, role_name)
    beg_of_month = Time.zone.parse('1-8-2021').beginning_of_month
    ind = 0
    30.times do
      params = { date: beg_of_month + ind.day, distance: 5 + ind, location: 'Lahore', time: 20 + ind }
      VCR.use_cassette("#{role_name}_#{ind + 1}") do
        post '/api/v1/jogging_events', headers: headers, params: params.to_json
      end
      ind += 1
    end
  end
end
