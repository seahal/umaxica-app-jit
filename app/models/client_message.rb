# frozen_string_literal: true

# == Schema Information
#
# Table name: client_messages
# Database name: message
#
#  id              :uuid             not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  public_id       :uuid
#  user_message_id :uuid
#
# Indexes
#
#  index_client_messages_on_user_message_id  (user_message_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_message_id => user_messages.id)
#

class ClientMessage < MessageRecord
  include ::PublicId

  belongs_to :user_message, optional: true, inverse_of: :client_messages
end
