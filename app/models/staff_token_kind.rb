# == Schema Information
#
# Table name: staff_token_kinds
# Database name: token
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class StaffTokenKind < TokenRecord
  # id is a string, manually managed
  self.primary_key = :id

  has_many :staff_tokens, dependent: :restrict_with_error
end
