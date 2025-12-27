# frozen_string_literal: true

class FixIdentitySchemaConsistency < ActiveRecord::Migration[8.2]
  def change
    # Avatar Assignment - Index
    remove_index :avatar_assignments, column: :user_id, if_exists: true
    add_index :avatar_assignments, :user_id

    # One Time Passwords FK
    # Ensure user_id is uuid to match users table
    reversible do |dir|
      dir.up do
        if connection.column_exists?(:user_identity_one_time_passwords, :user_id, :binary)
          remove_column :user_identity_one_time_passwords, :user_id
          add_column :user_identity_one_time_passwords,
                     :user_id,
                     :uuid,
                     null: false,
                     default: -> { "uuidv7()" }
          change_column_default :user_identity_one_time_passwords, :user_id, nil
        end
      end
    end

    remove_foreign_key :user_identity_one_time_passwords, :users, column: :user_id, if_exists: true
    add_foreign_key :user_identity_one_time_passwords, :users, column: :user_id, validate: false
  end
end
