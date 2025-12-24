class FixDefaultsAndConstraints < ActiveRecord::Migration[8.2]
  def change
    reversible do |dir|
      dir.up do
        change_table :role_assignments, bulk: true do |t|
          t.change_default :staff_id, from: nil, to: "00000000-0000-0000-0000-000000000000"
          t.change_default :user_id, from: nil, to: "00000000-0000-0000-0000-000000000000"
        end
        change_column_default :user_identity_one_time_passwords, :user_identity_one_time_password_status_id, from: "", to: "NONE"
        up_only { execute("UPDATE user_identity_one_time_passwords SET user_identity_one_time_password_status_id = 'NONE' WHERE user_identity_one_time_password_status_id = ''") }
      end
      dir.down do
        change_table :role_assignments, bulk: true do |t|
          t.change_default :staff_id, from: "00000000-0000-0000-0000-000000000000", to: nil
          t.change_default :user_id, from: "00000000-0000-0000-0000-000000000000", to: nil
        end
        change_column_default :user_identity_one_time_passwords, :user_identity_one_time_password_status_id, from: "NONE", to: ""
      end
    end
  end
end
