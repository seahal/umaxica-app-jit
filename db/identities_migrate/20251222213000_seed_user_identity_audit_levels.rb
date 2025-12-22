class SeedUserIdentityAuditLevels < ActiveRecord::Migration[8.2]
  LEVELS = %w[NONE DEBUG INFO WARN ERROR FATAL UNKNOWN].freeze

  def up
    LEVELS.each do |level|
      execute <<~SQL.squish
        INSERT INTO user_identity_audit_levels (id, created_at, updated_at)
        VALUES ('#{level}', NOW(), NOW())
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end

  def down
    execute <<~SQL.squish
      DELETE FROM user_identity_audit_levels
      WHERE id IN (#{LEVELS.map { |level| "'#{level}'" }.join(", ")})
    SQL
  end
end
