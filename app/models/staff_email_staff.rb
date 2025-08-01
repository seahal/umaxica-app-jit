# frozen_string_literal: true

class StaffEmailStaff < TokensRecord
  belongs_to :email, foreign_key: true, inverse_of: :staff_email_staffs
  belongs_to :staff, foreign_key: true, inverse_of: :staff_email_staffs
end
