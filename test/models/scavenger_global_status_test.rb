# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: scavenger_global_statuses
# Database name: activity
#
#  id :bigint           not null, primary key
#
require "test_helper"

class ScavengerGlobalStatusTest < ActiveSupport::TestCase
  test "class is defined" do
    assert_equal "ScavengerGlobalStatus", ScavengerGlobalStatus.name
  end
end
