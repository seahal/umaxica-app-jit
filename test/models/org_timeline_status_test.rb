# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_statuses
# Database name: news
#
#  id :bigint           not null, primary key
#

require "test_helper"

class OrgTimelineStatusTest < ActiveSupport::TestCase
  def setup
    @model_class = OrgTimelineStatus
  end

  test "inherits from NewsRecord" do
    assert_operator OrgTimelineStatus, :<, NewsRecord
  end

  test "status constants are defined" do
    assert_equal 1, OrgTimelineStatus::NOTHING
    assert_equal 2, OrgTimelineStatus::ACTIVE
    assert_equal 3, OrgTimelineStatus::INACTIVE
    assert_equal 4, OrgTimelineStatus::PENDING
    assert_equal 5, OrgTimelineStatus::DELETED
    assert_equal 6, OrgTimelineStatus::DRAFT
    assert_equal 7, OrgTimelineStatus::ARCHIVED
  end
end
