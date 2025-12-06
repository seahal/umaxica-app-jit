class StakeholderTest < ActiveSupport::TestCase
  %w[User Staff].each do |klass|
    test "#{klass} is a ..." do
      assert_includes klass.constantize.included_modules, Stakeholder
    end
  end

  test "user and staff are different classes" do
    assert_not_equal User, Staff
  end
end
