# frozen_string_literal: true

class CreateStaffEmailStaffs < ActiveRecord::Migration[7.2]
  #   def change
  #     # FIXME: need hashed partition.
  #     create_table :staff_email_staffs, id: false, force: :cascade do |t|
  #       t.belongs_to :staff, null: false, foreign_key: true, type: :uuid
  #
  #       # FIXME I want to use column type=staff
  #       t.string :email_address, null: false
  #
  #       # need index. this is because i do not want to set id.
  #       t.index [ "staff_id" ], name: "index_staff_email_staffs_staff_id"
  #       t.index [ "email_address" ], name: "index_staff_email_staffs_email_address", unique: true
  #     end
  #
  #     add_foreign_key :staff_email_staffs, :emails, column: :email_address, primary_key: :address, on_delete: :cascade
  #    end
end
