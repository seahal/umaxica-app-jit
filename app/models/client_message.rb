# frozen_string_literal: true

# == Schema Information
#
# Table name: client_messages
# Database name: message
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  public_id       :uuid             not null
#  user_message_id :bigint
#
# Indexes
#
#  index_client_messages_on_public_id        (public_id) UNIQUE
#  index_client_messages_on_user_message_id  (user_message_id)
#
# Foreign Keys
#
#  fk_client_messages_on_user_message_id_cascade  (user_message_id => user_messages.id) ON DELETE => cascade
#

class ClientMessage < MessageRecord
  include ::PublicId

  belongs_to :user_message, optional: true, inverse_of: :client_messages
end
