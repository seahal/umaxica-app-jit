# typed: false
# == Schema Information
#
# Table name: com_timeline_tags
# Database name: news
#
#  id                         :bigint           not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  com_timeline_id            :bigint           not null
#  com_timeline_tag_master_id :bigint           default(0), not null
#
# Indexes
#
#  idx_com_timeline_tags_on_master_and_timeline  (com_timeline_tag_master_id,com_timeline_id) UNIQUE
#  index_com_timeline_tags_on_com_timeline_id    (com_timeline_id)
#
# Foreign Keys
#
#  fk_com_timeline_tags_on_com_timeline_tag_master_id  (com_timeline_tag_master_id => com_timeline_tag_masters.id)
#  fk_rails_...                                        (com_timeline_id => com_timelines.id) ON DELETE => cascade
#

# frozen_string_literal: true

class ComTimelineTag < NewsRecord
  belongs_to :com_timeline, inverse_of: :com_timeline_tags
  belongs_to :com_timeline_tag_master,
             primary_key: :id,
             inverse_of: :com_timeline_tags

  validates :com_timeline_tag_master_id,
            uniqueness: { scope: :com_timeline_id,
                          message: :already_tagged, }
end
