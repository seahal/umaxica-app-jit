# == Schema Information
#
# Table name: staff_token_kinds
#
#  id :string           not null, primary key
#

# frozen_string_literal: true

class StaffTokenKind < TokenRecord
  # id is a string, manually managed
  self.primary_key = :id

  has_many :staff_tokens
end
