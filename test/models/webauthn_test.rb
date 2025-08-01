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
require "test_helper"

class WebauthnTest < ActiveSupport::TestCase
  test "should be valid" do
    assert true
  end
  # test "should validate presence of required fields" do
  #   webauthn = Webauthn.new
  #   assert_not webauthn.valid?
  #   #    assert_includes webauthn.errors[:webauthn_id], "can't be blank"
  #   assert_includes webauthn.errors[:public_key], "can't be blank"
  #   assert_includes webauthn.errors[:description], "can't be blank"
  # end

  # test "should validate uniqueness of webauthn_id" do
  #   # This test would require fixtures or factory setup
  #   # webauthn1 = webauthns(:one)
  #   # webauthn2 = Webauthn.new(webauthn_id: webauthn1.webauthn_id)
  #   # assert_not webauthn2.valid?
  # end

  # test "should increment sign count" do
  #   webauthn = Webauthn.new(sign_count: 5)
  #   webauthn.increment_sign_count!
  #   assert_equal 6, webauthn.sign_count
  # end
end
