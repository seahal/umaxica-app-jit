# typed: false
# == Schema Information
#
# Table name: user_client_revocations
# Database name: principal
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_client_revocations_on_client_id              (client_id)
#  index_user_client_revocations_on_user_id_and_client_id  (user_id,client_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#

# frozen_string_literal: true

require "test_helper"

class UserClientRevocationTest < ActiveSupport::TestCase
  setup do
    UserStatus.find_or_create_by!(id: UserStatus::NONE)
    create_user_and_status
    @user = User.find_by!(public_id: "one_id")
  end

  def create_user_and_status
    UserStatus.find_or_create_by!(id: UserStatus::NONE)
    User.find_or_create_by!(public_id: "one_id") do |u|
      u.status_id = UserStatus::NONE
    end
  end

  def create_client
    ClientStatus.find_or_create_by!(id: ClientStatus::NEYO)
    # Need a division for the client
    DivisionStatus.find_or_create_by!(id: DivisionStatus::NEYO)
    OrganizationStatus.find_or_create_by!(id: OrganizationStatus::NEYO)
    # Workspace/Organization (division -> workspace)
    # Check Division model if needed, but assuming optional or simple setup
    organization =
      Organization.find_or_create_by!(domain: "root.local") do |w|
        w.name = "Root"
        w.workspace_status_id = OrganizationStatus::NEYO
      end
    div = Division.create!(organization: organization, division_status_id: DivisionStatus::NEYO, name: "Test Div")

    Client.create!(
      status_id: ClientStatus::NEYO,
      client_status_id: ClientStatus::NEYO,
      division: div,
    )
  end

  test "can create valid record" do
    create_user_and_status
    client = create_client
    revocation = UserClientRevocation.new(
      user: @user,
      client: client,
    )

    assert_predicate revocation, :valid?
  end
end
