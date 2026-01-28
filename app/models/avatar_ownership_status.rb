# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_ownership_statuses
# Database name: avatar
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AvatarOwnershipStatus < AvatarRecord
  include StringPrimaryKey

  has_many :avatar_ownership_periods, dependent: :restrict_with_error
end
