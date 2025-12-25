# rubocop:disable Rails/BulkChangeTable
class AddUsesRemainingToIdentitySecrets < ActiveRecord::Migration[8.2]
  def change
    add_column :staff_identity_secrets, :uses_remaining, :integer, default: 1, null: false
    add_column :user_identity_secrets, :uses_remaining, :integer, default: 1, null: false

    add_check_constraint :staff_identity_secrets, "uses_remaining >= 0",
                         name: "chk_staff_identity_secrets_uses_remaining_non_negative"
    add_check_constraint :user_identity_secrets, "uses_remaining >= 0",
                         name: "chk_user_identity_secrets_uses_remaining_non_negative"

    add_index :staff_identity_secrets, :staff_id unless index_exists?(:staff_identity_secrets, :staff_id)
    add_index :user_identity_secrets, :user_id unless index_exists?(:user_identity_secrets, :user_id)
  end
end
# rubocop:enable Rails/BulkChangeTable
