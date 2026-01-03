# == Schema Information
#
# Table name: user_client_impersonations
#
#  id         :uuid             not null, primary key
#  user_id    :uuid             not null
#  client_id  :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_client_impersonations_on_client_id              (client_id)
#  index_user_client_impersonations_on_user_id                (user_id)
#  index_user_client_impersonations_on_user_id_and_client_id  (user_id,client_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class UserClientImpersonationTest < ActiveSupport::TestCase
  setup do
    UserIdentityStatus.find_or_create_by!(id: "NEYO")
    create_user_and_status
    @user = User.find_by!(public_id: "one_id")
  end

  def create_user_and_status
    UserIdentityStatus.find_or_create_by!(id: "NEYO")
    User.find_or_create_by!(public_id: "one_id") do |u|
      u.status_id = "NEYO"
    end
  end

  def create_client
    ClientIdentityStatus.find_or_create_by!(id: "NEYO")
    DivisionStatus.find_or_create_by!(id: "NEYO")
    Workspace.find_or_create_by!(id: "00000000-0000-0000-0000-000000000000") do |w|
      w.name = "Root"
      w.domain = "root.local"
      w.parent_organization = "00000000-0000-0000-0000-000000000000"
    end
    div = Division.create!(organization_id: "00000000-0000-0000-0000-000000000000", division_status_id: "NEYO")
    Client.create!(status_id: "NEYO", division: div)
  end

  test "can create valid record" do
    create_user_and_status
    client = create_client
    impersonation = UserClientImpersonation.new(
      user: @user,
      client: client,
    )
    assert_predicate impersonation, :valid?
  end
end
