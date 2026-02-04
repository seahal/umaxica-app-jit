# frozen_string_literal: true

class RenameUserIdentityEmailStatusIdToUserEmailStatusId < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      # Remove foreign key constraint
      remove_foreign_key :user_emails, column: :user_identity_email_status_id

      # Remove index
      remove_index :user_emails, name: :index_user_emails_on_user_identity_email_status_id

      # Rename column
      rename_column :user_emails, :user_identity_email_status_id, :user_email_status_id

      # Add index with new name
      add_index :user_emails, :user_email_status_id

      # Add foreign key constraint with new column name
      add_foreign_key :user_emails, :user_email_statuses, column: :user_email_status_id
    end
  end
end
