# == Schema Information
#
# Table name: com_timeline_tag_masters
# Database name: news
#
#  id        :integer          default(0), not null, primary key
#  parent_id :integer          default(0), not null
#
# Indexes
#
#  index_com_timeline_tag_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => com_timeline_tag_masters.id)
#

# frozen_string_literal: true

require "test_helper"

class ComTimelineTagMasterTest < ActiveSupport::TestCase
  include TimelineIntegerTreeTests

  private

  def treeable_class
    ComTimelineTagMaster
  end
end
