# == Schema Information
#
# Table name: app_timeline_category_masters
# Database name: news
#
#  id        :bigint           not null, primary key
#  parent_id :bigint           not null
#
# Indexes
#
#  index_app_timeline_category_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_app_timeline_category_masters_parent  (parent_id => app_timeline_category_masters.id)
#

# frozen_string_literal: true

require "test_helper"

class AppTimelineCategoryMasterTest < ActiveSupport::TestCase
  include TimelineIntegerTreeTests

  private

  def treeable_class
    AppTimelineCategoryMaster
  end
end
