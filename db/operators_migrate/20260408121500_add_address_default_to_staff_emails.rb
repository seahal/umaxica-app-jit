# frozen_string_literal: true

class AddAddressDefaultToStaffEmails < ActiveRecord::Migration[8.2]
  def change
    change_column_default(:staff_emails, :address, from: nil, to: "")
  end
end
