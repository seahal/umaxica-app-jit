# frozen_string_literal: true

class ValidateAddStaffIdentityTelephoneStatusToStaffIdentityTelephones < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(:staff_identity_telephones, :staff_identity_telephone_statuses)
  end
end
