# frozen_string_literal: true

# == Schema Information
#
# Table name: user_messages
#
#  id         :uuid             not null, primary key
#  user_id    :uuid             not null
#  public_id  :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_messages_on_user_id  (user_id)
#

class UserMessage < MessageRecord
  include ::PublicId

  self.implicit_order_column = :created_at

  belongs_to :user, inverse_of: :user_messages
  has_many :client_messages, inverse_of: :user_message, dependent: :delete_all
end
