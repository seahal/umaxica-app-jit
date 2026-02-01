# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_token_statuses
# Database name: token
#
#  id :integer          not null, primary key
#

class StaffTokenStatus < TokenRecord
  include CodeIdentifiable

  # Status constants
  NEYO = "NEYO"
  has_many :staff_tokens, dependent: :restrict_with_error
end
