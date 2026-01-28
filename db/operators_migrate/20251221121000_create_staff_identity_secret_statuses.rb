# frozen_string_literal: true

# rubocop:disable Rails/CreateTableWithTimestamps
class CreateStaffIdentitySecretStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table :staff_identity_secret_statuses, id: :string, limit: 255, primary_key: :id
  end

  def down
    drop_table :staff_identity_secret_statuses
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
