# == Schema Information
#
# Table name: org_timeline_tags
#
#  id                         :uuid             not null, primary key
#  org_timeline_id            :uuid             not null
#  org_timeline_tag_master_id :string(255)      not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_org_timeline_tags_on_org_timeline_tag_master_id  (org_timeline_tag_master_id)
#  index_org_timeline_tags_unique                         (org_timeline_id,org_timeline_tag_master_id) UNIQUE
#

# frozen_string_literal: true

class OrgTimelineTag < NewsRecord
  include ::CatTag

  belongs_to :org_timeline, inverse_of: :org_timeline_tags
  belongs_to :org_timeline_tag_master,
             primary_key: :id,
             inverse_of: :org_timeline_tags

  validates :org_timeline_tag_master_id,
            length: { maximum: 255 },
            uniqueness: { scope: :org_timeline_id,
                          message: :already_tagged, }
end
