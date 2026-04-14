# typed: false
# frozen_string_literal: true

require "test_helper"

module Verification
  class UserTest < ActiveSupport::TestCase
    test "is a valid concern module" do
      assert_kind_of Module, Verification::User
      assert_kind_of ActiveSupport::Concern, Verification::User
    end
  end

  class StaffTest < ActiveSupport::TestCase
    test "is a valid concern module" do
      assert_kind_of Module, Verification::Staff
      assert_kind_of ActiveSupport::Concern, Verification::Staff
    end

    test "defines actor_staff? method" do
      assert Verification::Staff.private_method_defined?(:actor_staff?)
    end
  end

  class CustomerTest < ActiveSupport::TestCase
    test "is a valid concern module" do
      assert_kind_of Module, Verification::Customer
      assert_kind_of ActiveSupport::Concern, Verification::Customer
    end
  end

  class ViewerTest < ActiveSupport::TestCase
    test "is a valid concern module" do
      assert_kind_of Module, Verification::Viewer
      assert_kind_of ActiveSupport::Concern, Verification::Viewer
    end

    test "defines enforce_verification_if_required method" do
      assert Verification::Viewer.private_method_defined?(:enforce_verification_if_required)
    end
  end
end
