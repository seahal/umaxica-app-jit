# frozen_string_literal: true

class AddExpiresAtToStaffIdentitySecrets < ActiveRecord::Migration[8.2]
  def change
    safety_assured { add_column(:staff_identity_secrets, :expires_at, :datetime, null: false, default: -> { "'infinity'" }) }
    safety_assured { add_index(:staff_identity_secrets, :expires_at) }
  end
end
