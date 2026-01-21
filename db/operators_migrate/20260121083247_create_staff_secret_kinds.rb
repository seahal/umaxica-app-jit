# frozen_string_literal: true

# rubocop:disable Rails/CreateTableWithTimestamps
class CreateStaffSecretKinds < ActiveRecord::Migration[8.2]
  def up
    create_table :staff_secret_kinds, id: :string, limit: 255, primary_key: :id
  end

  def down
    drop_table :staff_secret_kinds
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
