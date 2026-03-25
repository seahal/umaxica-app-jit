# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_statuses
# Database name: guest
#
#  id :bigint           not null, primary key
#

require "test_helper"

class CustomerStatusTest < ActiveSupport::TestCase
  test "has customer association" do
    assert_respond_to CustomerStatus.new, :customers
    assert_equal :has_many, CustomerStatus.reflect_on_association(:customers).macro
  end
end
