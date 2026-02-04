# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_secrets
# Database name: operator
#
#  id                              :bigint           not null, primary key
#  last_used_at                    :datetime
#  name                            :string           not null
#  password_digest                 :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  public_id                       :string(21)       not null
#  staff_id                        :bigint           not null
#  staff_identity_secret_status_id :bigint           default(1), not null
#  staff_secret_kind_id            :bigint           default(2), not null
#
# Indexes
#
#  index_staff_secrets_on_public_id                        (public_id) UNIQUE
#  index_staff_secrets_on_staff_id                         (staff_id)
#  index_staff_secrets_on_staff_identity_secret_status_id  (staff_identity_secret_status_id)
#  index_staff_secrets_on_staff_secret_kind_id             (staff_secret_kind_id)
#
# Foreign Keys
#
#  fk_rails_...                              (staff_id => staffs.id)
#  fk_rails_...                              (staff_identity_secret_status_id => staff_secret_statuses.id)
#  fk_staff_secrets_on_staff_secret_kind_id  (staff_secret_kind_id => staff_secret_kinds.id)
#

class StaffSecret < OperatorRecord
  alias_attribute :staff_secret_status_id, :staff_identity_secret_status_id
  include ::PublicId
  include ::Secret
  include StaffSecret::Kinds

  MAX_SECRETS_PER_STAFF = 10
  attr_accessor :raw_secret

  attribute :staff_identity_secret_status_id, default: StaffSecretStatus::ACTIVE
  attribute :staff_secret_kind_id, default: StaffSecretKind::LOGIN

  belongs_to :staff
  belongs_to :staff_secret_status,
             inverse_of: :staff_secrets,
             optional: true,
             foreign_key: :staff_identity_secret_status_id
  belongs_to :staff_secret_kind, inverse_of: :staff_secrets

  validates :staff_identity_secret_status_id, numericality: { only_integer: true }
  validates :staff_secret_kind_id, numericality: { only_integer: true }
  validate :enforce_secret_limit, on: :create

  def self.identity_secret_status_class
    StaffSecretStatus
  end

  def self.identity_secret_status_id_column
    :staff_identity_secret_status_id
  end

  def self.generate_raw_secret(length: SECRET_PASSWORD_LENGTH)
    SecureRandom.base58(length)
  end

  def to_param
    public_id
  end

  private

  def enforce_secret_limit
    return unless staff_id

    count = self.class.where(staff_id: staff_id).count
    return if count < MAX_SECRETS_PER_STAFF

    errors.add(:base, :too_many, message: "exceeds maximum secrets per staff (#{MAX_SECRETS_PER_STAFF})")
  end
end
