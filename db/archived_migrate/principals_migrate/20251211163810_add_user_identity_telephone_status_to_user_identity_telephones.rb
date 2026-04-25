# frozen_string_literal: true

class AddUserIdentityTelephoneStatusToUserIdentityTelephones < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column(
      :user_identity_telephones, :user_identity_telephone_status_id, :string, limit: 255,
                                                                              default: "UNVERIFIED", null: false,
    ) unless column_exists?(
      :user_identity_telephones, :user_identity_telephone_status_id,
    )
    add_index(:user_identity_telephones, :user_identity_telephone_status_id, algorithm: :concurrently) unless index_exists?(
      :user_identity_telephones, :user_identity_telephone_status_id,
    )
    add_foreign_key(:user_identity_telephones, :user_identity_telephone_statuses, validate: false) unless foreign_key_exists?(
      :user_identity_telephones, :user_identity_telephone_statuses,
    )
  end
end
