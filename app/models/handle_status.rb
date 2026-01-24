# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_statuses
# Database name: avatar
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class HandleStatus < AvatarRecord
  include StringPrimaryKey

  has_many :handles, dependent: :restrict_with_error
end
