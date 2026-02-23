# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_messages
# Database name: message
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  public_id  :string           default(""), not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_messages_on_public_id  (public_id) UNIQUE
#  index_user_messages_on_user_id    (user_id)
#

class UserMessage < MessageRecord
  include ::PublicId

  belongs_to :user, inverse_of: :user_messages
  has_many :client_messages, inverse_of: :user_message, dependent: :delete_all
end
