# == Schema Information
#
# Table name: google_auths
#
#  id            :uuid             not null, primary key
#  access_token  :text
#  email         :string
#  expires_at    :datetime
#  image_url     :string
#  name          :string
#  provider      :string
#  raw_info      :text
#  refresh_token :text
#  uid           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :uuid             not null
#
# Indexes
#
#  index_google_auths_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class GoogleAuthTest < ActiveSupport::TestCase
  setup do
    @user = User.new  # Assume User model exists
    @valid_attributes = {
      user: @user,
      uid: "google_123456789",
      email: "user@gmail.com",
      name: "John Doe",
      provider: "google",
      access_token: "access_token_123",
      refresh_token: "refresh_token_456",
      expires_at: 1.hour.from_now,
      image_url: "https://example.com/avatar.jpg",
      raw_info: '{"id":"123456789","name":"John Doe"}'
    }
  end

  # Basic model structure tests
  test "should inherit from IdentifiersRecord" do
    assert GoogleAuth < IdentifiersRecord
  end

  test "should belong to user" do
    association = GoogleAuth.reflect_on_association(:user)
    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  # Basic validation tests
  test "should be valid with valid attributes" do
    google_auth = GoogleAuth.new(@valid_attributes)
    assert google_auth.valid?
  end

  # test "should require user association" do
  #   google_auth = GoogleAuth.new(@valid_attributes.except(:user))
  #   assert_not google_auth.valid?
  #   assert_includes google_auth.errors[:user], "must exist"
  # end

  # Field validation tests
  test "should allow all fields to be present" do
    google_auth = GoogleAuth.new(@valid_attributes)
    assert google_auth.valid?
    
    google_auth.save!
    assert_equal @valid_attributes[:uid], google_auth.uid
    assert_equal @valid_attributes[:email], google_auth.email
    assert_equal @valid_attributes[:name], google_auth.name
    assert_equal @valid_attributes[:provider], google_auth.provider
  end

  test "should handle optional fields as nil" do
    minimal_attributes = {
      user: @user,
      uid: "google_minimal"
    }
    google_auth = GoogleAuth.new(minimal_attributes)
    assert google_auth.valid?
    
    google_auth.save!
    assert_nil google_auth.email
    assert_nil google_auth.name
    assert_nil google_auth.access_token
  end

  # Token and expiration tests
  test "should store access and refresh tokens" do
    google_auth = GoogleAuth.create!(@valid_attributes)
    assert_equal "access_token_123", google_auth.access_token
    assert_equal "refresh_token_456", google_auth.refresh_token
  end

  test "should handle token expiration" do
    past_time = 1.hour.ago
    google_auth = GoogleAuth.new(@valid_attributes.merge(expires_at: past_time))
    google_auth.save!
    assert google_auth.expires_at < Time.current
  end

  test "should store raw OAuth info as JSON" do
    google_auth = GoogleAuth.create!(@valid_attributes)
    assert_equal '{"id":"123456789","name":"John Doe"}', google_auth.raw_info
  end

  # Provider-specific tests
  test "should store Google provider information" do
    google_auth = GoogleAuth.create!(@valid_attributes)
    assert_equal "google", google_auth.provider
    assert_equal "user@gmail.com", google_auth.email
    assert_equal "https://example.com/avatar.jpg", google_auth.image_url
  end

  # User relationship tests
  test "should be associated with correct user" do
    google_auth = GoogleAuth.create!(@valid_attributes)
    assert_equal @user, google_auth.user
  end
end
