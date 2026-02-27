# frozen_string_literal: true

class AddStatusAndContextToUserOccurrences < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    add_column :user_occurrences, :status_id, :bigint, default: 1, null: true unless column_exists?(:user_occurrences, :status_id)
    add_check_constraint :user_occurrences, "status_id IS NOT NULL", name: "user_occurrences_status_id_null", validate: false

    add_column :user_occurrences, :event_type, :string, default: "", null: false unless column_exists?(:user_occurrences, :event_type)
    add_column :user_occurrences, :context, :jsonb, default: {}, null: false unless column_exists?(:user_occurrences, :context)

    add_index :user_occurrences, %i(status_id created_at), algorithm: :concurrently unless index_exists?(:user_occurrences, %i(status_id created_at))
    add_index :user_occurrences, %i(event_type created_at), algorithm: :concurrently unless index_exists?(:user_occurrences, %i(event_type created_at))
  end

  def down
    remove_check_constraint :user_occurrences, name: "user_occurrences_status_id_null" if check_constraint_exists?(:user_occurrences, name: "user_occurrences_status_id_null")
  end
end
