# == Schema Information
#
# Table name: webauthns
#
#  id          :uuid             not null, primary key
#  description :string           not null
#  public_key  :text             not null
#  sign_count  :bigint           default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  external_id :uuid             not null
#  user_id     :binary           not null
#  webauthn_id :binary           not null
#
class Webauthn < IdentifiersRecord
  belongs_to :user

  def increment_sign_count!
    update!(sign_count: sign_count + 1)
  end
end
