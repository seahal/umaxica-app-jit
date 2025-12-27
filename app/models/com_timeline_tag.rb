# == Schema Information
#
# Table name: com_timeline_tags
#
#  id                         :uuid             not null, primary key
#  com_timeline_id            :uuid             not null
#  com_timeline_tag_master_id :string(255)      not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_com_timeline_tags_on_com_timeline_tag_master_id  (com_timeline_tag_master_id)
#  index_com_timeline_tags_unique                         (com_timeline_id,com_timeline_tag_master_id) UNIQUE
#

# frozen_string_literal: true

class ComTimelineTag < NewsRecord
  belongs_to :com_timeline, inverse_of: :com_timeline_tags
  belongs_to :com_timeline_tag_master,
             primary_key: :id,
             inverse_of: :com_timeline_tags

  validates :com_timeline_tag_master_id,
            length: { maximum: 255 },
            uniqueness: { scope: :com_timeline_id,
                          message: :already_tagged, }
end
