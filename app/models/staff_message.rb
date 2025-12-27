# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_messages
#
#  id         :uuid             not null, primary key
#  staff_id   :uuid
#  public_id  :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_staff_messages_on_staff_id  (staff_id)
#

class StaffMessage < MessageRecord
  include ::PublicId

  belongs_to :staff, optional: true, inverse_of: :staff_messages
end
