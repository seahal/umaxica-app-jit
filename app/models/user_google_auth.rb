# frozen_string_literal: true

# == Schema Information
#
# Table name: user_google_auths
#
#  id         :uuid             not null, primary key
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_user_google_auths_on_user_id  (user_id)
#
class UserGoogleAuth < IdentifiersRecord
  belongs_to :user
end
