# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_visibilities
# Database name: guest
#
#  id :bigint           not null, primary key
#

require "test_helper"

class CustomerVisibilityTest < ActiveSupport::TestCase
  test "has customer association" do
    assert_respond_to CustomerVisibility.new, :customers
    assert_equal :has_many, CustomerVisibility.reflect_on_association(:customers).macro
  end
end
