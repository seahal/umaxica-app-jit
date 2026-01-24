# == Schema Information
#
# Table name: com_timeline_category_masters
# Database name: news
#
#  id         :string(255)      not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :string(255)      default("NEYO"), not null
#
# Indexes
#
#  index_com_timeline_category_masters_on_lower_id   (lower((id)::text)) UNIQUE
#  index_com_timeline_category_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => com_timeline_category_masters.id)
#

# frozen_string_literal: true

require "test_helper"

class ComTimelineCategoryMasterTest < ActiveSupport::TestCase
  include TreeableSharedTests

  private

  def treeable_class
    ComTimelineCategoryMaster
  end
end
