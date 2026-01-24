# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_moniker_statuses
# Database name: avatar
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AvatarMonikerStatus < AvatarRecord
  include StringPrimaryKey

  has_many :avatar_monikers, dependent: :restrict_with_error
end
