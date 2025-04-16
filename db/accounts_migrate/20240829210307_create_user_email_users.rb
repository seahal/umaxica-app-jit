# frozen_string_literal: true

class CreateUserEmailUsers < ActiveRecord::Migration[7.2]
  #   def change
  #     # FIXME: need hashed partition.
  #     create_table :user_email_users, id: false, force: :cascade do |t|
  #       t.references :user, null: false, foreign_key: true, type: :uuid, index: false
  #
  #       t.string :email_address, null: false
  #
  #       # Need index. this is because i do not want to set id.
  #       t.index [ "user_id" ], name: "index_user_email_users_user_id"
  #       t.index [ "email_address" ], name: "index_user_email_users_email_address", unique: true
  #     end
  #
  #     add_foreign_key :user_email_users, :emails, column: :email_address, primary_key: :address, on_delete: :cascade
  #   end
end
