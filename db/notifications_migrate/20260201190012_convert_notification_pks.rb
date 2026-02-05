# frozen_string_literal: true

class ConvertNotificationPks < ActiveRecord::Migration[8.0]
  def up

    # Drop
    drop_table :client_notifications, if_exists: true
    drop_table :admin_notifications, if_exists: true
    drop_table :user_notifications, if_exists: true
    drop_table :staff_notifications, if_exists: true

    # Recreate
    create_table :staff_notifications do |t|
      t.bigint :staff_id, null: false # Changed from uuid to bigint (Staff is now bigint)
      t.string :public_id, null: false, default: ""
      t.timestamps
      t.index :staff_id
    end

    create_table :user_notifications do |t|
      t.bigint :user_id, null: false # Changed from uuid to bigint (User is now bigint)
      t.string :public_id, null: false, default: ""
      t.timestamps
      t.index :user_id
    end

    create_table :admin_notifications do |t|
      t.string :public_id, null: false, default: ""
      t.bigint :staff_notification_id, null: false
      t.timestamps
      t.index :staff_notification_id
    end

    create_table :client_notifications do |t|
      t.string :public_id, null: false, default: ""
      t.bigint :user_notification_id, null: false
      t.timestamps
      t.index :user_notification_id
    end

    # FKs
    # staff_id -> staffs (in operator/identifier tables, likely external or same DB if mapped)
    # user_id -> users (in principal/identifier tables)
    # We add FKs only if tables exist in same DB. Usually Notification DB is separate.
    # But usually we don't enforce Cross-DB FKs.
    # Assuming Notification DB is separate:
    # We can't add FK to staffs/users if they are in different DB.
    # We CAN add FK to internal tables (staff_notification_id, user_notification_id).

    add_foreign_key :admin_notifications, :staff_notifications, validate: false
    add_foreign_key :client_notifications, :user_notifications, validate: false
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
