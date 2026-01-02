# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_ownership_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AvatarOwnershipStatus < IdentitiesRecord
  include StringPrimaryKey

  has_many :avatar_ownership_periods, dependent: :restrict_with_error

  validates :id, format: { with: /\A[A-Z0-9_]+\z/ }
end
