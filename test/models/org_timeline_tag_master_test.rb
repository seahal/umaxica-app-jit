# == Schema Information
#
# Table name: org_timeline_tag_masters
# Database name: news
#
#  id        :integer          default(0), not null, primary key
#  parent_id :integer          default(0), not null
#
# Indexes
#
#  index_org_timeline_tag_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => org_timeline_tag_masters.id)
#

# frozen_string_literal: true

require "test_helper"

class OrgTimelineTagMasterTest < ActiveSupport::TestCase
  include TimelineIntegerTreeTests

  private

  def treeable_class
    OrgTimelineTagMaster
  end
end
