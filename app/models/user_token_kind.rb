# == Schema Information
#
# Table name: user_token_kinds
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class UserTokenKind < TokenRecord
  # id is a string, manually managed
  self.primary_key = :id

  has_many :user_tokens, dependent: :restrict_with_error
end
