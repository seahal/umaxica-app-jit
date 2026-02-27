# frozen_string_literal: true

class FixPreferenceStatusDefaults < ActiveRecord::Migration[8.2]
  def change
    # Set default status_id to 2 (NEYO) which is valid. 0 is invalid.
    change_column_default :app_preferences, :status_id, from: 0, to: 2
    change_column_default :com_preferences, :status_id, from: 0, to: 2
    change_column_default :org_preferences, :status_id, from: 0, to: 2
  end
end
