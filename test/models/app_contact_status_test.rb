require "test_helper"

class AppContactStatusTest < ActiveSupport::TestCase
  include ContactStatusModelTestHelper

  def setup
    @model_class = AppContactStatus
    @status = AppContactStatus.create!(title: "ACTIVE")
    @contact = AppContact.create!(
        app_contact_status: @status
    )
  end

  test "should have many app_contacts" do
    assert_includes @status.app_contacts, @contact
  end

  test "should nullify app_contact_status_id when destroyed" do
    # The model says `dependent: :nullify`
    # Foreign key is `contact_status_title`? No, let's check model.
    # `foreign_key: :contact_status_title`

    @status.destroy
    @contact.reload

    assert_nil @contact.contact_status_title
  end
end
