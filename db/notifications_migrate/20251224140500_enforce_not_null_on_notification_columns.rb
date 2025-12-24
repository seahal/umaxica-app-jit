class EnforceNotNullOnNotificationColumns < ActiveRecord::Migration[8.2]
  NIL_UUID = '00000000-0000-0000-0000-000000000000'

  def change
    reversible do |dir|
      dir.up do
        execute "UPDATE staff_notifications SET public_id = '#{NIL_UUID}' WHERE public_id IS NULL"
        execute "UPDATE staff_notifications SET staff_id = '#{NIL_UUID}' WHERE staff_id IS NULL"
      end
    end

    change_table :staff_notifications, bulk: true do |t|
      t.change_null :public_id, false, NIL_UUID
      t.change_default :public_id, from: nil, to: NIL_UUID

      t.change_null :staff_id, false, NIL_UUID
      t.change_default :staff_id, from: nil, to: NIL_UUID
    end

    reversible do |dir|
      dir.up do
        execute "UPDATE user_notifications SET public_id = '#{NIL_UUID}' WHERE public_id IS NULL"
        execute "UPDATE user_notifications SET user_id = '#{NIL_UUID}' WHERE user_id IS NULL"
      end
    end

    change_table :user_notifications, bulk: true do |t|
      t.change_null :public_id, false, NIL_UUID
      t.change_default :public_id, from: nil, to: NIL_UUID

      t.change_null :user_id, false, NIL_UUID
      t.change_default :user_id, from: nil, to: NIL_UUID
    end
  end
end
