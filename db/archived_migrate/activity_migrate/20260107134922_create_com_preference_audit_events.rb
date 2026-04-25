# frozen_string_literal: true

class CreateComPreferenceAuditEvents < ActiveRecord::Migration[8.2]
  def change
    create_table(:com_preference_audit_events, id: { type: :string, limit: 255, default: "NEYO" }) do |t|
      t.timestamps
    end
  end
end
