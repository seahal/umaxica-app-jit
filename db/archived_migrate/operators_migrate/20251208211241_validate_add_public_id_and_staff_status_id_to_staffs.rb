# frozen_string_literal: true

class ValidateAddPublicIdAndStaffStatusIdToStaffs < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key :staffs, :staff_identity_statuses
  end
end
