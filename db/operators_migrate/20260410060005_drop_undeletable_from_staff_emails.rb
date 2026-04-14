# frozen_string_literal: true

class DropUndeletableFromStaffEmails < ActiveRecord::Migration[8.0]
  def up
    safety_assured { remove_column(:staff_emails, :undeletable) }
  end

  def down
    add_column(:staff_emails, :undeletable, :boolean, null: false, default: false)
  end
end
