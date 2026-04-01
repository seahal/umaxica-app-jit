# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_visibilities
# Database name: guest
#
#  id :bigint           not null, primary key
#

class CustomerVisibility < GuestRecord
  NOBODY = 0
  CUSTOMER = 1
  STAFF = 2
  BOTH = 3

  has_many :customers,
           foreign_key: :visibility_id,
           dependent: :restrict_with_error,
           inverse_of: :visibility
end
