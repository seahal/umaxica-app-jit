# frozen_string_literal: true

# == Schema Information
#
# Table name: user_visibilities
# Database name: principal
#
#  id :bigint           not null, primary key
#
class UserVisibility < PrincipalRecord
  NOBODY = 0
  USER = 1
  STAFF = 2
  BOTH = 3

  has_many :users,
           foreign_key: :visibility_id,
           dependent: :restrict_with_error,
           inverse_of: :visibility
end
