# == Schema Information
#
# Table name: user_identity_social_googles
#
#  id                                    :uuid             not null, primary key
#  created_at                            :datetime         not null
#  email                                 :string           default(""), not null
#  expires_at                            :integer          not null
#  image                                 :string           default(""), not null
#  provider                              :string           default("google_oauth2"), not null
#  refresh_token                         :string           default(""), not null
#  token                                 :string           default(""), not null
#  uid                                   :string           default(""), not null
#  updated_at                            :datetime         not null
#  user_id                               :uuid             not null
#  user_identity_social_google_status_id :string(255)      default("ACTIVE"), not null
#
# Indexes
#
#  idx_on_user_identity_social_google_status_id_7bdb8753df  (user_identity_social_google_status_id)
#  index_user_identity_social_googles_on_expires_at         (expires_at)
#  index_user_identity_social_googles_on_uid_and_provider   (uid,provider) UNIQUE
#  index_user_identity_social_googles_on_user_id_unique     (user_id) UNIQUE
#

require "test_helper"

class UserIdentitySocialGoogleTest < ActiveSupport::TestCase
  test "allows only one google auth per user" do
    user = users(:one)

    UserIdentitySocialGoogle.create!(
      user: user,
      uid: "uid-1",
      token: "token-1",
      expires_at: 1.week.from_now.to_i,
      user_identity_social_google_status: user_identity_social_google_statuses(:active)
    )

    duplicate = UserIdentitySocialGoogle.new(
      user: user,
      token: "token-2"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "はすでに存在します"
  end
end
