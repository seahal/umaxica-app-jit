# frozen_string_literal: true

class ChangeOtpCounterToText < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      change_column(:user_otp_challenges, :otp_counter, :text)
    end
  end

  def down
    safety_assured do
      change_column(:user_otp_challenges, :otp_counter, :bigint)
    end
  end
end
