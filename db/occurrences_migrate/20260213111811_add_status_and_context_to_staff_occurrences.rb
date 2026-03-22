# frozen_string_literal: true

class AddStatusAndContextToStaffOccurrences < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    add_column(:staff_occurrences, :status_id, :bigint, default: 1, null: true) unless column_exists?(
      :staff_occurrences, :status_id,
    )
    add_check_constraint(
      :staff_occurrences, "status_id IS NOT NULL", name: "staff_occurrences_status_id_null",
                                                   validate: false,
    )

    add_column(:staff_occurrences, :event_type, :string, default: "", null: false) unless column_exists?(
      :staff_occurrences, :event_type,
    )
    add_column(
      :staff_occurrences, :context, :jsonb, default: {},
                                            null: false,
    ) unless column_exists?(
      :staff_occurrences,
      :context,
    )

    add_index(:staff_occurrences, %i(status_id created_at), algorithm: :concurrently) unless index_exists?(
      :staff_occurrences, %i(status_id created_at),
    )
    add_index(:staff_occurrences, %i(event_type created_at), algorithm: :concurrently) unless index_exists?(
      :staff_occurrences, %i(event_type created_at),
    )
  end

  def down
    remove_check_constraint(:staff_occurrences, name: "staff_occurrences_status_id_null") if check_constraint_exists?(
      :staff_occurrences, name: "staff_occurrences_status_id_null",
    )
  end
end
