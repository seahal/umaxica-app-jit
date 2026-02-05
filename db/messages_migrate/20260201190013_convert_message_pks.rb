# frozen_string_literal: true

class ConvertMessagePks < ActiveRecord::Migration[8.0]
  def up
    # Drop
    drop_table :client_messages, if_exists: true
    drop_table :admin_messages, if_exists: true
    drop_table :user_messages, if_exists: true
    drop_table :staff_messages, if_exists: true

    # Recreate
    create_table :staff_messages do |t|
      t.bigint :staff_id, null: false # Bigint reference to staff
      t.string :public_id, null: false, default: ""
      t.timestamps
      t.index :staff_id
    end

    create_table :user_messages do |t|
      t.bigint :user_id, null: false # Bigint reference to user
      t.string :public_id, null: false, default: ""
      t.timestamps
      t.index :user_id
    end

    create_table :admin_messages do |t|
      t.bigint :staff_message_id
      t.string :public_id, null: false, default: ""
      t.timestamps
      t.index :staff_message_id
    end

    create_table :client_messages do |t|
      t.bigint :user_message_id
      t.string :public_id, null: false, default: ""
      t.timestamps
      t.index :user_message_id
    end

    # FKs
    add_foreign_key :admin_messages, :staff_messages, validate: false
    add_foreign_key :client_messages, :user_messages, validate: false
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
