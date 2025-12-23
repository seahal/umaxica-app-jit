require "test_helper"

class NotificationServiceTest < ActiveSupport::TestCase
  test "NotificationService class exists and can be referenced" do
    assert_equal NotificationService, NotificationService
  end

  test "NotificationService can be instantiated" do
    service = NotificationService.new

    assert_instance_of NotificationService, service
  end

  test "NotificationService responds to new" do
    assert_respond_to NotificationService, :new
  end
end
