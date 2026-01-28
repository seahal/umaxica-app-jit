# frozen_string_literal: true

class AddLockVersionToComAndOrgTimelines < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      %i[com_timelines org_timelines].each do |table_name|
        add_column table_name, :lock_version, :integer, null: false, default: 0
      end
    end
  end
end
