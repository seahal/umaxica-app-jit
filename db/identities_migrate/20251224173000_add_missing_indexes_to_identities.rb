class AddMissingIndexesToIdentities < ActiveRecord::Migration[8.2]
  def change
    add_index :staff_identity_audits, [ :actor_type, :actor_id ]
    add_index :user_identity_audits, [ :actor_type, :actor_id ]
  end
end
