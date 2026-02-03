# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_statuses
# Database name: news
#
#  id :bigint           not null, primary key
#

require "test_helper"

class ComTimelineStatusTest < ActiveSupport::TestCase
  def setup
    @model_class = ComTimelineStatus
  end

  test "inherits from NewsRecord" do
    assert_operator ComTimelineStatus, :<, NewsRecord
  end

  test "status constants are defined" do
    assert_equal 1, ComTimelineStatus::NEYO
    assert_equal 2, ComTimelineStatus::ACTIVE
    assert_equal 3, ComTimelineStatus::INACTIVE
    assert_equal 4, ComTimelineStatus::PENDING
    assert_equal 5, ComTimelineStatus::DELETED
    assert_equal 6, ComTimelineStatus::DRAFT
    assert_equal 7, ComTimelineStatus::ARCHIVED
  end
end
