# frozen_string_literal: true

class ValidateAddUserIdentityTelephoneStatusToUserIdentityTelephones < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(:user_identity_telephones, :user_identity_telephone_statuses)
  end
end
