# typed: false
# frozen_string_literal: true

class AddDeviceIdDigestToTokens < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    # UserToken
    add_column(:user_tokens, :device_id_digest, :string) unless column_exists?(:user_tokens, :device_id_digest)
    add_index(:user_tokens, :device_id_digest, algorithm: :concurrently) unless index_exists?(:user_tokens, :device_id_digest)

    # StaffToken
    add_column(:staff_tokens, :device_id_digest, :string) unless column_exists?(:staff_tokens, :device_id_digest)
    add_index(:staff_tokens, :device_id_digest, algorithm: :concurrently) unless index_exists?(:staff_tokens, :device_id_digest)

    # CustomerToken
    add_column(:customer_tokens, :device_id_digest, :string) unless column_exists?(:customer_tokens, :device_id_digest)
    add_index(:customer_tokens, :device_id_digest, algorithm: :concurrently) unless index_exists?(:customer_tokens, :device_id_digest)
  end

  def down
    remove_index(:user_tokens, :device_id_digest) if index_exists?(:user_tokens, :device_id_digest)
    remove_column(:user_tokens, :device_id_digest) if column_exists?(:user_tokens, :device_id_digest)

    remove_index(:staff_tokens, :device_id_digest) if index_exists?(:staff_tokens, :device_id_digest)
    remove_column(:staff_tokens, :device_id_digest) if column_exists?(:staff_tokens, :device_id_digest)

    remove_index(:customer_tokens, :device_id_digest) if index_exists?(:customer_tokens, :device_id_digest)
    remove_column(:customer_tokens, :device_id_digest) if column_exists?(:customer_tokens, :device_id_digest)
  end
end
