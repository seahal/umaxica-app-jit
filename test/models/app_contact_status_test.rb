# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_statuses
# Database name: guest
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AppContactStatusTest < ActiveSupport::TestCase
  def setup
    @model_class = AppContactStatus
    @status = AppContactStatus.find_or_create_by!(id: AppContactStatus::NEYO)
    @contact = AppContact.create!(
      app_contact_status: @status,
      confirm_policy: "1",
    )
  end

  test "should have many app_contacts" do
    assert_includes @status.app_contacts, @contact
  end

  test "should restrict destroy when app contacts exist" do
    status = AppContactStatus.find_or_create_by!(id: AppContactStatus::EMAIL_PENDING)
    # Ensure a contact exists pointing to this status
    AppContact.create!(
      app_contact_status: status,
      public_id: "test_contact_#{SecureRandom.hex(4)}",
    )

    # With dependent: :restrict_with_error, destroy returns false and adds errors
    assert_not status.destroy
    assert_includes status.errors[:base].join, "app contacts"
  end

  test "id is numeric" do
    assert_kind_of Integer, @status.id
  end
end
