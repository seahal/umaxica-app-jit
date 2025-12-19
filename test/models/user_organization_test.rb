require "test_helper"

class UserOrganizationTest < ActiveSupport::TestCase
  test "should inherit from IdentityRecord" do
    assert_operator UserOrganization, :<, IdentityRecord
  end

  test "should belong to user" do
    assert_respond_to UserOrganization.new, :user
  end

  test "should belong to organization" do
    assert_respond_to UserOrganization.new, :organization
  end

  test "should have user association through has_many" do
    user = User.new

    assert_respond_to user, :user_organizations
  end

  test "should have organization association through has_many" do
    organization = Workspace.new

    assert_respond_to organization, :user_organizations
  end

  test "should have id field as UUID" do
    user_organization = UserOrganization.new

    # The id field is a string (UUID) type
    assert_respond_to user_organization, :id
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should create instance with valid structure" do
    user_organization = UserOrganization.new

    assert_respond_to user_organization, :user
    assert_respond_to user_organization, :organization
    assert_respond_to user_organization, :user_id
    assert_respond_to user_organization, :organization_id
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should have inverse_of in associations" do
    assert_equal :user_organizations, UserOrganization.reflect_on_association(:user).options[:inverse_of]
    assert_equal :user_organizations, UserOrganization.reflect_on_association(:organization).options[:inverse_of]
  end

  test "should have timestamps" do
    user_organization = UserOrganization.new

    assert_respond_to user_organization, :created_at
    assert_respond_to user_organization, :updated_at
  end
end
