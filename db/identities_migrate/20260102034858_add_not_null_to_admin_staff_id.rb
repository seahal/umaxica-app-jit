# frozen_string_literal: true

class AddNotNullToAdminStaffId < ActiveRecord::Migration[8.2]
  def change
    add_check_constraint :admins, "staff_id IS NOT NULL",
                         name: "admins_staff_id_null",
                         validate: false
  end
end
