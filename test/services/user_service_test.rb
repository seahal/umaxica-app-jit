
require "test_helper"

class UserServiceTest < ActiveSupport::TestCase
  def setup
    @service = UserService.new
  end

  test "should instantiate UserService" do
    assert_instance_of UserService, @service
  end
end
