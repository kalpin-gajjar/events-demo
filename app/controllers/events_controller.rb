class EventsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_event, only: [:show, :edit, :update, :destroy, :sync_event_with_google, :sync_event_with_microsoft]

  def index
    @events = current_user.events
  end

  def show; end

  def new
    @event = Event.new
  end

  def edit; end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to @event, notice: "Event was successfully created."
    else
      render :new
    end
  rescue Google::Apis::ClientError => error
    redirect_to events_path, notice: error.message
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: "Event was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to events_url, notice: "Event was successfully destroyed."
  end

  def sync_event_with_google
    ge = @event.get_google_event(@event.event_id, @event.user)
    if ge.status == "cancelled"
      @event.event_id = nil
      @event.destroy
      redirect_to events_path, notice: "Event was deleted from google calendar."
    else
      guests = ge.attendees.map { |at| at.email }.join(", ")
      @event.update(members: guests, title: ge.summary, description: ge.description, start_date: ge.start.date_time, end_date: ge.end.date_time)
      redirect_to event_path(@event), notice: "Event has been synced with google calendar successfully."
    end
  end

  def sync_event_with_microsoft
    time_zone = "India Standard Time"

    me = @event.get_microsoft_event(@event.user.access_token, time_zone, @event.event_id)
    if me == "cancelled"
      @event.event_id = nil
      @event.destroy
      redirect_to events_path, notice: "Event was deleted from microsoft calendar."
    else
      guests = me["attendees"].map { |a| a["emailAddress"]["address"] }.join(", ")
      @event.update(members: guests, title: me["subject"], description: me["body"]["content"], start_date: me["start"]["dateTime"], end_date: me["end"]["dateTime"])
      redirect_to event_path(@event), notice: "Event has been synced with microsoft calendar successfully."
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit!
  end
end
