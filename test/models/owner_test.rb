require "test_helper"

class OwnerTest < ActiveSupport::TestCase
  test "inherits from ApplicationRecord" do
    assert Owner < ApplicationRecord
  end
end

