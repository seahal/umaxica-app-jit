# == Schema Information
#
# Table name: staff_token_kinds
# Database name: token
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_staff_token_kinds_on_code  (code) UNIQUE
#
# frozen_string_literal: true

class StaffTokenKind < TokenRecord
  include CodeIdentifiable

  # id is a string, manually managed
  self.primary_key = :id
  self.record_timestamps = false

  has_many :staff_tokens, dependent: :restrict_with_error
end
