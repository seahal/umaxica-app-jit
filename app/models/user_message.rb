# frozen_string_literal: true

# == Schema Information
#
# Table name: user_messages
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  public_id  :uuid
#  updated_at :datetime         not null
#  user_id    :uuid
#

class UserMessage < MessageRecord
  include ::PublicId
end
