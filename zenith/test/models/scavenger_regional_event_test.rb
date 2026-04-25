# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: scavenger_regional_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#
require "test_helper"

class ScavengerRegionalEventTest < ActiveSupport::TestCase
  test "class is defined" do
    assert_equal "ScavengerRegionalEvent", ScavengerRegionalEvent.name
  end
end
