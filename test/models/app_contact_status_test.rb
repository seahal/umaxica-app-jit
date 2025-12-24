# == Schema Information
#
# Table name: app_contact_statuses
#
#  id           :string(255)      not null, primary key
#  active       :boolean          default(TRUE), not null
#  description  :string(255)      default(""), not null
#  parent_title :string(255)      default(""), not null
#  position     :integer          default(0), not null
#

require "test_helper"

class AppContactStatusTest < ActiveSupport::TestCase
  include ContactStatusModelTestHelper

  def setup
    @model_class = AppContactStatus
    @status = AppContactStatus.create!(id: "ACTIVE")
    @contact = AppContact.create!(
      app_contact_status: @status
    )
  end

  test "should have many app_contacts" do
    assert_includes @status.app_contacts, @contact
  end

  test "should nullify app_contact_status_id when destroyed" do
    # The model says `dependent: :nullify`
    # Foreign key is `contact_status_id`

    assert_raises(ActiveRecord::NotNullViolation) do
      @status.destroy
    end
    @contact.reload

    assert_equal "ACTIVE", @contact.contact_status_id
  end
end
