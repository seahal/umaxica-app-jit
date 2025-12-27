# == Schema Information
#
# Table name: org_timeline_categories
#
#  id                              :uuid             not null, primary key
#  org_timeline_id                 :uuid             not null
#  org_timeline_category_master_id :string(255)      not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
# Indexes
#
#  idx_on_org_timeline_category_master_id_fa21cb5b0c  (org_timeline_category_master_id)
#  index_org_timeline_categories_unique               (org_timeline_id) UNIQUE
#

# frozen_string_literal: true

class OrgTimelineCategory < NewsRecord
  include ::CatTag

  belongs_to :org_timeline, inverse_of: :category
  belongs_to :org_timeline_category_master,
             primary_key: :id,
             inverse_of: :org_timeline_categories

  validates :org_timeline_id, uniqueness: true
  validates :org_timeline_category_master_id, length: { maximum: 255 }
end
