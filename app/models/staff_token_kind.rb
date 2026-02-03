# == Schema Information
#
# Table name: staff_token_kinds
# Database name: token
#
#  id :bigint           not null, primary key
#
# frozen_string_literal: true

class StaffTokenKind < TokenRecord
  self.record_timestamps = false

  BROWSER_WEB = 1
  CLIENT_IOS = 2
  CLIENT_ANDROID = 3

  has_many :staff_tokens, dependent: :restrict_with_error
end
