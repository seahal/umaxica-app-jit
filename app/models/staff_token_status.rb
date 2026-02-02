# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_token_statuses
# Database name: token
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_staff_token_statuses_on_code  (code) UNIQUE
#

class StaffTokenStatus < TokenRecord
  include CodeIdentifiable

  # Status constants
  NEYO = "NEYO"
  has_many :staff_tokens, dependent: :restrict_with_error
end
