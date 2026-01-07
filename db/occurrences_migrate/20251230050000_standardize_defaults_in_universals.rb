# frozen_string_literal: true

class StandardizeDefaultsInUniversals < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      # Strings -> ""
      # event_id and level_id were identified as "NEYO" default strings
      change_column_default :com_contact_audits, :event_id, from: "NEYO", to: ""
      change_column_default :com_contact_audits, :level_id, from: "NEYO", to: ""
    end
  end
end
