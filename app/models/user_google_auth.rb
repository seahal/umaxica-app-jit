# frozen_string_literal: true

# == Schema Information
#
# Table name: user_google_auths
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class UserGoogleAuth < IdentifiersRecord
  belongs_to :user
end
