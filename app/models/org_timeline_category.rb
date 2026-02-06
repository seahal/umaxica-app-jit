# == Schema Information
#
# Table name: org_timeline_categories
# Database name: news
#
#  id                              :bigint           not null, primary key
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  org_timeline_category_master_id :bigint           default(0), not null
#  org_timeline_id                 :bigint           not null
#
# Indexes
#
#  idx_on_org_timeline_category_master_id_fa21cb5b0c  (org_timeline_category_master_id)
#  index_org_timeline_categories_unique               (org_timeline_id) UNIQUE
#
# Foreign Keys
#
#  fk_org_timeline_categories_on_org_timeline_category_master_id
#    (org_timeline_category_master_id => org_timeline_category_masters.id)
#  fk_rails_...
#    (org_timeline_id => org_timelines.id) ON DELETE => cascade
#

# frozen_string_literal: true

class OrgTimelineCategory < NewsRecord
  include ::CatTag

  belongs_to :org_timeline, inverse_of: :category
  belongs_to :org_timeline_category_master,
             primary_key: :id,
             inverse_of: :org_timeline_categories

  validates :org_timeline_id, uniqueness: true
end
