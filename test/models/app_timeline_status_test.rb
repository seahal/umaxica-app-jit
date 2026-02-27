# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_statuses
# Database name: news
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AppTimelineStatusTest < ActiveSupport::TestCase
  fixtures :app_timeline_statuses

  def setup
    @model_class = AppTimelineStatus
  end

  test "inherits from NewsRecord" do
    assert_operator AppTimelineStatus, :<, NewsRecord
  end

  test "accepts integer ids" do
    status = @model_class.new(id: 9)

    assert_predicate status, :valid?
  end

  test "constants are defined" do
    assert_equal 1, AppTimelineStatus::NOTHING
    assert_equal 2, AppTimelineStatus::ACTIVE
    assert_equal 3, AppTimelineStatus::INACTIVE
    assert_equal 4, AppTimelineStatus::PENDING
    assert_equal 5, AppTimelineStatus::DELETED
    assert_equal 6, AppTimelineStatus::DRAFT
    assert_equal 7, AppTimelineStatus::ARCHIVED
  end

  test "can find statuses by numeric id" do
    status = @model_class.find(AppTimelineStatus::NOTHING)

    assert_equal AppTimelineStatus::NOTHING, status.id
  end
end
