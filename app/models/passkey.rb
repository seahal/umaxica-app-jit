# == Schema Information
#
# Table name: passkeys
#
#  id                 :uuid             not null, primary key
#  active             :boolean
#  authenticator_type :integer
#  nickname           :string
#  public_key         :text
#  sign_count         :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  external_id        :string
#  user_id            :bigint           not null
#
# Indexes
#
#  index_passkeys_on_external_id  (external_id) UNIQUE
#  index_passkeys_on_user_id      (user_id)
#
class Passkey < IdentifiersRecord
  belongs_to :user

  validates :credential_id, presence: true, uniqueness: true
  validates :public_key, presence: true
  validates :user_handle, presence: true
  validates :nickname, presence: true
  validates :sign_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }

  def increment_sign_count!
    increment!(:sign_count)
    touch(:last_used_at)
  end

  def deactivate!
    update!(active: false)
  end
end
