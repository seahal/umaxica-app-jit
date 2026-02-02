# == Schema Information
#
# Table name: com_timeline_category_masters
# Database name: news
#
#  id        :bigint           not null, primary key
#  parent_id :bigint           not null
#
# Indexes
#
#  index_com_timeline_category_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_com_timeline_category_masters_parent  (parent_id => com_timeline_category_masters.id)
#

# frozen_string_literal: true

require "test_helper"

class ComTimelineCategoryMasterTest < ActiveSupport::TestCase
  include TimelineIntegerTreeTests

  private

  def treeable_class
    ComTimelineCategoryMaster
  end
end
