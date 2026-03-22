# frozen_string_literal: true

class StandardizeDefaultsInUniversals < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      # Strings -> ""
      # event_id and level_id were identified as "NEYO" default strings
      if table_exists?(:com_contact_audits)
        change_column_default(:com_contact_audits, :event_id, from: "NEYO", to: "") if column_exists?(
          :com_contact_audits, :event_id,
        )
        change_column_default(:com_contact_audits, :level_id, from: "NEYO", to: "") if column_exists?(
          :com_contact_audits, :level_id,
        )
      end
    end
  end
end
