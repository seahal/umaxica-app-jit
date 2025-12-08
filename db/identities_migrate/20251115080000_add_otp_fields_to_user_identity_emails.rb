# frozen_string_literal: true

class AddOtpFieldsToUserIdentityEmails < ActiveRecord::Migration[8.0]
  def change
    change_table :user_identity_emails, bulk: true do |t|
      t.string :otp_private_key
      t.text :otp_counter
      t.datetime :otp_expires_at
    end
  end
end
