class Event < ApplicationRecord
  include GoogleCalendarApi
  include MicrosoftCalendarApi

  CALENDAR_ID = "primary"
  belongs_to :user

  acts_as_paranoid

  after_create :publish_event_to_cal
  after_update :update_event_on_cal
  before_destroy :remove_event_from_cal

  def publish_event_to_cal
    if self.user.provider == "google_oauth2"
      self.create_google_event(self)
    else
      self.create_microsoft_event(self)
    end
  end

  def update_event_on_cal
    if self.user.provider == "google_oauth2"
      self.edit_google_event(self)
    else
      self.edit_microsoft_event(self)
    end
  end

  def remove_event_from_cal
    unless self.event_id.nil?
      if self.user.provider == "google_oauth2"
        self.delete_google_event(self)
      else
        self.delete_microsoft_event(self)
      end
    end
  end
end
