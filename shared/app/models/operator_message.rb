# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: operator_messages
# Database name: message
#
#  id               :bigint           not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  public_id        :string           default(""), not null
#  staff_message_id :bigint
#
# Indexes
#
#  index_operator_messages_on_public_id         (public_id) UNIQUE
#  index_operator_messages_on_staff_message_id  (staff_message_id)
#
# Foreign Keys
#
#  fk_admin_messages_on_staff_message_id_cascade  (staff_message_id => staff_messages.id) ON DELETE => cascade
#

class OperatorMessage < MessageRecord
  include ::PublicId

  belongs_to :staff_message, optional: true, inverse_of: :operator_messages
end
