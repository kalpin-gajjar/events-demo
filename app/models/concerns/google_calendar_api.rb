require "google/apis/calendar_v3"
require "google/api_client/client_secrets.rb"

module GoogleCalendarApi
  include ActiveSupport::Concern

  def get_google_calendar_client(current_user)
    client = Google::Apis::CalendarV3::CalendarService.new
    return unless (current_user.present? && current_user.access_token.present? && current_user.refresh_token.present?)
    secrets = Google::APIClient::ClientSecrets.new({
      "web" => {
        "access_token" => current_user.access_token,
        "refresh_token" => current_user.refresh_token,
        "client_id" => ENV["GOOGLE_API_KEY"],
        "client_secret" => ENV["GOOGLE_API_SECRET"],
      },
    })
    begin
      client.authorization = secrets.to_authorization
      client.authorization.grant_type = "refresh_token"

      if !current_user.present?
        client.authorization.refresh!
        current_user.update_attributes(
          access_token: client.authorization.access_token,
          refresh_token: client.authorization.refresh_token,
          expires_at: client.authorization.expires_at.to_i,
        )
      end
    rescue => e
      flash[:error] = "Your token has been expired. Please login again with google."
      redirect_to :back
    end
    client
  end

  def create_google_event(event)
    client = get_google_calendar_client(event.user)
    g_event = get_event(event)
    ge = client.insert_event(Event::CALENDAR_ID, g_event)
    event.update(google_event_id: ge.id)
  end

  def edit_google_event(event)
    client = get_google_calendar_client(event.user)
    g_event = client.get_event(Event::CALENDAR_ID, event.google_event_id)
    ge = get_event(event)
    client.update_event(Event::CALENDAR_ID, event.google_event_id, ge)
  end

  def get_event(event)
    attendees = event[:members].split(",").map { |t| { email: t.strip } }
    event = Google::Apis::CalendarV3::Event.new({
      summary: event[:title],
      location: "Bacancy Technology, Thaltej - Shilaj Rd, Ahmedabad, Gujarat 380059",
      description: event[:description],
      start: {
        date_time: event.start_date.to_datetime.to_s,
        time_zone: "Asia/Kolkata",
      # date_time: '2019-09-07T09:00:00-07:00',
      # time_zone: 'Asia/Kolkata',
      },
      end: {
        date_time: event.end_date.to_datetime.to_s,
        time_zone: "Asia/Kolkata",
      },
      attendees: attendees,
      reminders: {
        use_default: false,
        overrides: [
          Google::Apis::CalendarV3::EventReminder.new(reminder_method: "popup", minutes: 10),
          Google::Apis::CalendarV3::EventReminder.new(reminder_method: "email", minutes: 20),
        ],
      },
      notification_settings: {
        notifications: [
                         { type: "event_creation", method: "email" },
                         { type: "event_change", method: "email" },
                         { type: "event_cancellation", method: "email" },
                         { type: "event_response", method: "email" },
                       ],
      }, 'primary': true,
    })
  end

  def delete_google_event(event)
    client = get_google_calendar_client(event.user)
    client.delete_event(Event::CALENDAR_ID, event.google_event_id)
  end

  def get_google_event(event_id, user)
    client = get_google_calendar_client user
    g_event = client.get_event(Event::CALENDAR_ID, event_id)
  end
end
