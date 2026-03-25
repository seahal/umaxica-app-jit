# typed: false
# == Schema Information
#
# Table name: org_timeline_tag_masters
# Database name: publication
#
#  id        :bigint           not null, primary key
#  parent_id :bigint           not null
#
# Indexes
#
#  index_org_timeline_tag_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_org_timeline_tag_masters_parent  (parent_id => org_timeline_tag_masters.id)
#

# frozen_string_literal: true

require "test_helper"

class OrgTimelineTagMasterTest < ActiveSupport::TestCase
  include TreeableSharedTests

  test "treeable class is defined" do
    assert_equal OrgTimelineTagMaster, treeable_class
  end

  private

  def treeable_class
    OrgTimelineTagMaster
  end
end
