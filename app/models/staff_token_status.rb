# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_token_statuses
# Database name: token
#
#  id :bigint           not null, primary key
#

class StaffTokenStatus < TokenRecord
  ACTIVE = 1
  NEYO = 2
  has_many :staff_tokens, dependent: :restrict_with_error
end
