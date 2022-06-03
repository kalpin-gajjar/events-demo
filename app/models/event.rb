class Event < ApplicationRecord
  include GoogleCalendarApi
  CALENDAR_ID = "primary"
  belongs_to :user

  after_create :publish_event_to_gcal
  after_update :update_event_on_gcal
  before_destroy :remove_event_from_gcal

  def publish_event_to_gcal
    self.create_google_event(self)
  end

  def update_event_on_gcal
    self.edit_google_event(self)
  end

  def remove_event_from_gcal
    self.delete_google_event(self)
  end
end
