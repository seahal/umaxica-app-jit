# frozen_string_literal: true

class CreateUserSessions < ActiveRecord::Migration[7.2]
  #   def change
  #     # FIXME: need hashed partition.
  #     # TODO: Table are should be alike to id
  #     # Info: using this table as 多態(logged in PhoneNumber, EmailsAddress, GoogleAuth, AppleAuth)...
  #     create_table :user_sessions, id: :uuid do |t|
  #       t.references :user, null: false, foreign_key: true, type: :uuid
  #       t.string :sessioner_type
  #       t.references :sessioner
  #
  #       t.timestamps
  #     end
  #   end
end
