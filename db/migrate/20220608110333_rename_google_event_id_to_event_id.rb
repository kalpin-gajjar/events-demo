class RenameGoogleEventIdToEventId < ActiveRecord::Migration[5.2]
  def change
    rename_column :events, :google_event_id, :event_id
  end
end
