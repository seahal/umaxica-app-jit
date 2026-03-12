# typed: false
# frozen_string_literal: true

module StaffIdentifierDetection
  extend ActiveSupport::Concern

  private

  def find_staff_by_identifier(identifier)
    staff_email = StaffEmail.find_by(address: identifier)
    return staff_email.staff if staff_email

    Staff.find_by(public_id: Staff.normalize_public_id(identifier))
  end
end
