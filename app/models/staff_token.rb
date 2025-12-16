# frozen_string_literal: true

class StaffToken < TokensRecord
  belongs_to :staff
  belongs_to :staff_token_status
end
