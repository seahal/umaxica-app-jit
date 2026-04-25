# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: scavenger_global_events
# Database name: activity
#
#  id :bigint           not null, primary key
#
require "test_helper"

class ScavengerGlobalEventTest < ActiveSupport::TestCase
  test "class is defined" do
    assert_equal "ScavengerGlobalEvent", ScavengerGlobalEvent.name
  end
end
