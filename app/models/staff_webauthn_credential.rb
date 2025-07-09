# frozen_string_literal: true

class StaffWebauthnCredential < IdentifiersRecord
  belongs_to :staff

  validates :external_id, presence: true, uniqueness: true
  validates :public_key, presence: true
  validates :nickname, presence: true
  validates :sign_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  enum authenticator_type: {
    platform: 0,
    roaming: 1
  }

  scope :active, -> { where(active: true) }

  def increment_sign_count!
    increment!(:sign_count)
  end

  def deactivate!
    update!(active: false)
  end
end
