# typed: false
# frozen_string_literal: true

require "test_helper"

module Authorization
  class ViewerTest < ActiveSupport::TestCase
    test "is a valid concern module" do
      assert_kind_of Module, Authorization::Viewer
    end

    test "extends ActiveSupport::Concern" do
      assert_kind_of ActiveSupport::Concern, Authorization::Viewer
    end
  end

  class UserTest < ActiveSupport::TestCase
    test "is a valid concern module" do
      assert_kind_of Module, Authorization::User
      assert_kind_of ActiveSupport::Concern, Authorization::User
    end
  end

  class StaffTest < ActiveSupport::TestCase
    test "is a valid concern module" do
      assert_kind_of Module, Authorization::Staff
      assert_kind_of ActiveSupport::Concern, Authorization::Staff
    end
  end

  class CustomerTest < ActiveSupport::TestCase
    test "is a valid concern module" do
      assert_kind_of Module, Authorization::Customer
      assert_kind_of ActiveSupport::Concern, Authorization::Customer
    end
  end

  class ClientTest < ActiveSupport::TestCase
    test "is a valid concern module" do
      assert_kind_of Module, Authorization::Client
      assert_kind_of ActiveSupport::Concern, Authorization::Client
    end
  end
end
