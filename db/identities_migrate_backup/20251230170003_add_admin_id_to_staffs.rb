# frozen_string_literal: true

class AddAdminIdToStaffs < ActiveRecord::Migration[8.2]
  def change
    add_reference :staffs,
                  :admin,
                  foreign_key: { to_table: :admins, validate: false },
                  type: :uuid
  end
end
