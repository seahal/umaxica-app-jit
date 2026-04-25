# frozen_string_literal: true

class ValidateRenameStaffStatusIdToStaffIdentityStatusId < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key(:staffs, :staff_identity_statuses)
  end
end
