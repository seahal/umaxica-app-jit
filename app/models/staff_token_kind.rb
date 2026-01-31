# == Schema Information
#
# Table name: staff_token_kinds
# Database name: token
#
#  id :integer          not null, primary key
#
# frozen_string_literal: true

class StaffTokenKind < TokenRecord
  # id is a string, manually managed
  self.primary_key = :id
  self.record_timestamps = false

  has_many :staff_tokens, dependent: :restrict_with_error
end
