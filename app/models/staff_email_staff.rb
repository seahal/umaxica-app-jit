# frozen_string_literal: true

class StaffEmailStaff < TokensRecord
  belongs_to :email, foreign_key: true
  belongs_to :staff, foreign_key: true
end
