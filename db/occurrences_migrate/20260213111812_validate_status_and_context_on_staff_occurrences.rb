# frozen_string_literal: true

class ValidateStatusAndContextOnStaffOccurrences < ActiveRecord::Migration[8.2]
  def up
    validate_check_constraint(:staff_occurrences, name: "staff_occurrences_status_id_null")
    change_column_null(:staff_occurrences, :status_id, false)
    remove_check_constraint(:staff_occurrences, name: "staff_occurrences_status_id_null")
  end

  def down
    add_check_constraint(
      :staff_occurrences, "status_id IS NOT NULL", name: "staff_occurrences_status_id_null",
                                                   validate: false,
    )
    change_column_null(:staff_occurrences, :status_id, true)
  end
end
