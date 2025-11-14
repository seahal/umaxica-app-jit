# frozen_string_literal: true

# == Schema Information
#
# Table name: user_apple_auths
#
#  id         :uuid             not null, primary key
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
class UserAppleAuth < IdentitiesRecord
  belongs_to :user

  validates :token, presence: true
end
