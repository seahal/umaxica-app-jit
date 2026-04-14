# frozen_string_literal: true

class DropUndeletableFromUserEmails < ActiveRecord::Migration[8.0]
  def up
    safety_assured { remove_column(:user_emails, :undeletable) }
  end

  def down
    add_column(:user_emails, :undeletable, :boolean, null: false, default: false)
  end
end
