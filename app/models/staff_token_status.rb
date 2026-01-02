# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_token_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class StaffTokenStatus < TokensRecord
  include UppercaseId

  has_many :staff_tokens, dependent: :restrict_with_error

  # Status constants
  NEYO = "NEYO"

  validates :id, format: { with: /\A[A-Z0-9_]+\z/ }
end
