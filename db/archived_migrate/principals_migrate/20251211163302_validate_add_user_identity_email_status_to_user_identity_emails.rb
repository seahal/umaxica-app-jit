# frozen_string_literal: true

class ValidateAddUserIdentityEmailStatusToUserIdentityEmails < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(:user_identity_emails, :user_identity_email_statuses)
  end
end
