# frozen_string_literal: true

class EnforceNotNullOnNotificationColumns < ActiveRecord::Migration[8.2]
  DEFAULT_PUBLIC_ID = ""

  def change
    reversible do |dir|
      dir.up do
        execute "UPDATE staff_notifications SET public_id = '' WHERE public_id IS NULL"
      end
    end

    change_table :staff_notifications, bulk: true do |t|
      t.change_null :public_id, false, DEFAULT_PUBLIC_ID
      t.change_default :public_id, from: nil, to: DEFAULT_PUBLIC_ID
      t.change_null :staff_id, false
    end

    reversible do |dir|
      dir.up do
        execute "UPDATE user_notifications SET public_id = '' WHERE public_id IS NULL"
      end
    end

    change_table :user_notifications, bulk: true do |t|
      t.change_null :public_id, false, DEFAULT_PUBLIC_ID
      t.change_default :public_id, from: nil, to: DEFAULT_PUBLIC_ID
      t.change_null :user_id, false
    end
  end
end
