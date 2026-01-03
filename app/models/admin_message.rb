# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_messages
#
#  id               :uuid             not null, primary key
#  public_id        :uuid
#  staff_message_id :uuid
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_admin_messages_on_staff_message_id  (staff_message_id)
#

class AdminMessage < MessageRecord
  include ::PublicId

  belongs_to :staff_message, optional: true, inverse_of: :admin_messages
end
