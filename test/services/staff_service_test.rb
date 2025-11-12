
require "test_helper"

class StaffServiceTest < ActiveSupport::TestCase
  def setup
    @service = UserService.new
  end

  test "should instantiate StaffService" do
    assert_instance_of UserService, @service
  end
end
