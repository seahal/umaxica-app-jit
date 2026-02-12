# frozen_string_literal: true

class EnsurePreferenceAuditLevelDefaults < ActiveRecord::Migration[8.2]
  def up
    # Insert defaults directly using SQL to avoid model connection issues
    safety_assured do
      [1].each do |id|
        execute "INSERT INTO app_preference_audit_levels (id) VALUES (#{id}) ON CONFLICT DO NOTHING"
        execute "INSERT INTO com_preference_audit_levels (id) VALUES (#{id}) ON CONFLICT DO NOTHING"
        execute "INSERT INTO org_preference_audit_levels (id) VALUES (#{id}) ON CONFLICT DO NOTHING"
      end
    end
  end

  def down
    # No-op: leave reference data in place
  end
end
