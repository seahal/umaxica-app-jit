class CreateStaffIdentityAudits < ActiveRecord::Migration[8.2]
  def change
    create_table :staff_identity_audits, id: :uuid do |t|
      t.references :staff, null: false, foreign_key: true, type: :uuid
      t.string :event_type
      t.datetime :timestamp
      t.string :ip_address
      t.uuid :actor_id
      t.text :previous_value
      t.text :current_value

      t.timestamps
    end
  end
end
