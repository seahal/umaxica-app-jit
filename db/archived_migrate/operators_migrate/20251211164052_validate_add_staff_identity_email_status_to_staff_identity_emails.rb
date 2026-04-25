# frozen_string_literal: true

class ValidateAddStaffIdentityEmailStatusToStaffIdentityEmails < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(:staff_identity_emails, :staff_identity_email_statuses)
  end
end
