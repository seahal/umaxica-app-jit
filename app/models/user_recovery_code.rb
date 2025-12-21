# frozen_string_literal: true

class UserRecoveryCode < IdentitiesRecord
  attr_accessor :confirm_create_recovery_code

  belongs_to :user

  validates :recovery_code_digest, presence: true
  validates :expires_in, presence: true

  before_validation :ensure_expiration, on: :create

  private

    def ensure_expiration
      self.expires_in ||= 30.days.from_now.to_date
    end
end
