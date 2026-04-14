# frozen_string_literal: true

class AddOtpLastSentAtToCustomerTelephones < ActiveRecord::Migration[8.0]
  def change
    add_column :customer_telephones, :otp_last_sent_at, :datetime, default: -Float::INFINITY, null: false
  end
end
