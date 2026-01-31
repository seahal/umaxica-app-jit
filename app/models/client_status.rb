# frozen_string_literal: true

class ClientStatus < PrincipalRecord
  self.record_timestamps = false

  NEYO = 0

  has_many :clients,
           foreign_key: :status_id,
           dependent: :restrict_with_error,
           inverse_of: :client_status
  validates :id, uniqueness: true
  validates :id, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
