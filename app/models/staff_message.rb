class StaffMessage < MessageRecord
  include ::PublicId

  belongs_to :staff, optional: true, inverse_of: :staff_messages
end
