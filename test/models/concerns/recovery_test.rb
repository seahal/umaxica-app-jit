require "test_helper"

class RecoveryTest < ActiveSupport::TestCase
  class DummyRecovery
    include ActiveModel::Model
    include Recovery
  end

  test "can include recovery concern" do
    assert_includes DummyRecovery.included_modules, Recovery
  end

  test "is an ActiveSupport::Concern" do
    assert_includes Recovery.singleton_class.included_modules, ActiveSupport::Concern
  end
end
