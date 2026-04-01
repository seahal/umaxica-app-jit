# typed: false
# frozen_string_literal: true

class AddDeviceIdDigestToOperatorPreferences < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_column(:org_preferences, :device_id_digest, :string) unless column_exists?(:org_preferences, :device_id_digest)
    add_index(:org_preferences, :device_id_digest, algorithm: :concurrently) unless index_exists?(:org_preferences, :device_id_digest)
  end

  def down
    remove_index(:org_preferences, :device_id_digest) if index_exists?(:org_preferences, :device_id_digest)
    remove_column(:org_preferences, :device_id_digest) if column_exists?(:org_preferences, :device_id_digest)
  end
end

