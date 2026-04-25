# typed: false
# == Schema Information
#
# Table name: com_timeline_tag_masters
# Database name: publication
#
#  id        :bigint           not null, primary key
#  parent_id :bigint           not null
#
# Indexes
#
#  index_com_timeline_tag_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_com_timeline_tag_masters_parent  (parent_id => com_timeline_tag_masters.id)
#

# frozen_string_literal: true

require "test_helper"

class ComTimelineTagMasterTest < ActiveSupport::TestCase
  include TreeableSharedTests

  test "treeable class is defined" do
    assert_equal ComTimelineTagMaster, treeable_class
  end

  private

  def treeable_class
    ComTimelineTagMaster
  end
end
