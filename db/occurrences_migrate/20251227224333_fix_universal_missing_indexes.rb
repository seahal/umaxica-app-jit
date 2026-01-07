# frozen_string_literal: true

class FixUniversalMissingIndexes < ActiveRecord::Migration[8.2]
  def change
    # Add indexes for polymorphic actor association (User/Staff)
    add_index :user_identity_audits, [:actor_type, :actor_id], name: "index_user_identity_audits_on_actor", if_not_exists: true
    add_index :staff_identity_audits, [:actor_type, :actor_id], name: "index_staff_identity_audits_on_actor", if_not_exists: true
  end
end
