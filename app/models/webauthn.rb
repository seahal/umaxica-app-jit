# == Schema Information
#
# Table name: webauthns
#
#  id          :uuid             not null, primary key
#  description :string           not null
#  public_key  :text             not null
#  sign_count  :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :binary           not null
#  webauthn_id :binary           not null
#
# Indexes
#
#  index_webauthns_on_user_id      (user_id)
#  index_webauthns_on_webauthn_id  (webauthn_id) UNIQUE
#
class Webauthn < IdentifiersRecord
  belongs_to :user

  validates :webauthn_id, presence: true, uniqueness: true
  validates :public_key, presence: true
  validates :description, presence: true
  validates :sign_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def increment_sign_count!
    increment!(:sign_count)
  end
end
