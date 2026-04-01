# typed: false
# frozen_string_literal: true

class AddDeviceIdDigestToAppPreferences < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_column(:app_preferences, :device_id_digest, :string) unless column_exists?(:app_preferences, :device_id_digest)
    add_index(:app_preferences, :device_id_digest, algorithm: :concurrently) unless index_exists?(:app_preferences, :device_id_digest)
  end

  def down
    remove_index(:app_preferences, :device_id_digest) if index_exists?(:app_preferences, :device_id_digest)
    remove_column(:app_preferences, :device_id_digest) if column_exists?(:app_preferences, :device_id_digest)
  end
end
