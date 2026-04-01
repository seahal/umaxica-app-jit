# frozen_string_literal: true

class CreateAppPreferenceStatuses < ActiveRecord::Migration[8.2]
  def change
    create_table(:app_preference_statuses, id: { type: :string, limit: 255, default: "NEYO" }) do |t|
      t.timestamps
    end
  end
end
