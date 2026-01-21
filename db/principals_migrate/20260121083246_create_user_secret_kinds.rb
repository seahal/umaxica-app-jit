# frozen_string_literal: true

# rubocop:disable Rails/CreateTableWithTimestamps
class CreateUserSecretKinds < ActiveRecord::Migration[8.2]
  def up
    create_table :user_secret_kinds, id: :string, limit: 255, primary_key: :id
  end

  def down
    drop_table :user_secret_kinds
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
