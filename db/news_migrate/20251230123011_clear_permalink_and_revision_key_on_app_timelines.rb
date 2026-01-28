# frozen_string_literal: true

class ClearPermalinkAndRevisionKeyOnAppTimelines < ActiveRecord::Migration[8.2]
  def up
    table_name = :app_timelines
    return unless table_exists?(table_name)

    safety_assured do
      execute("UPDATE #{table_name} SET permalink = ''") if column_exists?(table_name, :permalink)
      execute("UPDATE #{table_name} SET revision_key = ''") if column_exists?(table_name, :revision_key)
    end
  end

  def down
    # No-op because the original values cannot be restored.
  end
end
