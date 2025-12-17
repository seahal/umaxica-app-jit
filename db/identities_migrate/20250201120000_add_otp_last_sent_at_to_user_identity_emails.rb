class AddOtpLastSentAtToUserIdentityEmails < ActiveRecord::Migration[8.2]
  def change
    add_column :user_identity_emails, :otp_last_sent_at, :datetime
    add_index :user_identity_emails, :otp_last_sent_at

    add_column :staff_identity_emails, :otp_last_sent_at, :datetime
    add_index :staff_identity_emails, :otp_last_sent_at
  end
end
