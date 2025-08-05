# == Schema Information
#
# Table name: user_tokens
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
class UserToken < TokensRecord
end
