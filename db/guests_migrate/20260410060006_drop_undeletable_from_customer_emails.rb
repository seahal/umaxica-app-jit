# frozen_string_literal: true

class DropUndeletableFromCustomerEmails < ActiveRecord::Migration[8.0]
  def up
    safety_assured { remove_column(:customer_emails, :undeletable) }
  end

  def down
    add_column(:customer_emails, :undeletable, :boolean, null: false, default: false)
  end
end
