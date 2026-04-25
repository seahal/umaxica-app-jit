# frozen_string_literal: true

class AddStaffIdentityTelephoneStatusToStaffIdentityTelephones < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column(
      :staff_identity_telephones, :staff_identity_telephone_status_id, :string, limit: 255,
                                                                                default: "UNVERIFIED", null: false,
    ) unless column_exists?(
      :staff_identity_telephones, :staff_identity_telephone_status_id,
    )
    add_index(:staff_identity_telephones, :staff_identity_telephone_status_id, algorithm: :concurrently) unless index_exists?(
      :staff_identity_telephones, :staff_identity_telephone_status_id,
    )
    add_foreign_key(:staff_identity_telephones, :staff_identity_telephone_statuses, validate: false) unless foreign_key_exists?(
      :staff_identity_telephones, :staff_identity_telephone_statuses,
    )
  end
end
