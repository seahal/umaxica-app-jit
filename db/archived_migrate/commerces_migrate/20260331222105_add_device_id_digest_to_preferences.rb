# typed: false
# frozen_string_literal: true

class AddDeviceIdDigestToPreferences < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    # AppPreference
    add_column(:app_preferences, :device_id_digest, :string) unless column_exists?(:app_preferences, :device_id_digest)
    add_index(:app_preferences, :device_id_digest, algorithm: :concurrently) unless index_exists?(:app_preferences, :device_id_digest)

    # ComPreference
    add_column(:com_preferences, :device_id_digest, :string) unless column_exists?(:com_preferences, :device_id_digest)
    add_index(:com_preferences, :device_id_digest, algorithm: :concurrently) unless index_exists?(:com_preferences, :device_id_digest)

    # OrgPreference (commerce schema)
    add_column(:org_preferences, :device_id_digest, :string) unless column_exists?(:org_preferences, :device_id_digest)
    add_index(:org_preferences, :device_id_digest, algorithm: :concurrently) unless index_exists?(:org_preferences, :device_id_digest)
  end

  def down
    remove_index(:app_preferences, :device_id_digest) if index_exists?(:app_preferences, :device_id_digest)
    remove_column(:app_preferences, :device_id_digest) if column_exists?(:app_preferences, :device_id_digest)

    remove_index(:com_preferences, :device_id_digest) if index_exists?(:com_preferences, :device_id_digest)
    remove_column(:com_preferences, :device_id_digest) if column_exists?(:com_preferences, :device_id_digest)

    remove_index(:org_preferences, :device_id_digest) if index_exists?(:org_preferences, :device_id_digest)
    remove_column(:org_preferences, :device_id_digest) if column_exists?(:org_preferences, :device_id_digest)
  end
end
