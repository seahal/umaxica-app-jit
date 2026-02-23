# typed: false
# == Schema Information
#
# Table name: org_timeline_tags
# Database name: news
#
#  id                         :bigint           not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  org_timeline_id            :bigint           not null
#  org_timeline_tag_master_id :bigint           default(0), not null
#
# Indexes
#
#  idx_org_timeline_tags_on_master_and_timeline  (org_timeline_tag_master_id,org_timeline_id) UNIQUE
#  index_org_timeline_tags_on_org_timeline_id    (org_timeline_id)
#
# Foreign Keys
#
#  fk_org_timeline_tags_on_org_timeline_tag_master_id  (org_timeline_tag_master_id => org_timeline_tag_masters.id)
#  fk_rails_...                                        (org_timeline_id => org_timelines.id) ON DELETE => cascade
#

# frozen_string_literal: true

class OrgTimelineTag < NewsRecord
  include ::CatTag

  belongs_to :org_timeline, inverse_of: :org_timeline_tags
  belongs_to :org_timeline_tag_master,
             primary_key: :id,
             inverse_of: :org_timeline_tags

  validates :org_timeline_tag_master_id,
            uniqueness: { scope: :org_timeline_id,
                          message: :already_tagged, }
end
