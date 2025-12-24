# == Schema Information
#
# Table name: staff_messages
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  public_id  :uuid
#  staff_id   :uuid
#  updated_at :datetime         not null
#

class StaffMessage < MessageRecord
  include ::PublicId

  belongs_to :staff, optional: true, inverse_of: :staff_messages
end
