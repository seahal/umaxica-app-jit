# frozen_string_literal: true

# == Schema Information
#
# Table name: client_messages
#
#  id              :uuid             not null, primary key
#  public_id       :uuid
#  user_message_id :uuid
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_client_messages_on_user_message_id  (user_message_id)
#

class ClientMessage < MessageRecord
  include ::PublicId

  self.implicit_order_column = :created_at

  belongs_to :user_message, optional: true, inverse_of: :client_messages
end
