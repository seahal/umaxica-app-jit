# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: member_messages
# Database name: message
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  public_id       :string           default(""), not null
#  user_message_id :bigint
#
# Indexes
#
#  index_member_messages_on_public_id        (public_id) UNIQUE
#  index_member_messages_on_user_message_id  (user_message_id)
#
# Foreign Keys
#
#  fk_member_messages_on_user_message_id_cascade  (user_message_id => user_messages.id) ON DELETE => cascade
#

class MemberMessage < MessageRecord
  include ::PublicId

  belongs_to :user_message, optional: true, inverse_of: :member_messages
end
