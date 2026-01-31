# == Schema Information
#
# Table name: com_timeline_tags
# Database name: news
#
#  id                         :uuid             not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  com_timeline_id            :uuid             not null
#  com_timeline_tag_master_id :integer          default(0), not null
#
# Indexes
#
#  index_com_timeline_tags_on_com_timeline_tag_master_id  (com_timeline_tag_master_id)
#
# Foreign Keys
#
#  fk_rails_...  (com_timeline_id => com_timelines.id) ON DELETE => cascade
#  fk_rails_...  (com_timeline_tag_master_id => com_timeline_tag_masters.id)
#

# frozen_string_literal: true

class ComTimelineTag < NewsRecord
  belongs_to :com_timeline, inverse_of: :com_timeline_tags
  belongs_to :com_timeline_tag_master,
             primary_key: :id,
             inverse_of: :com_timeline_tags

  validates :com_timeline_tag_master_id,
            presence: true,
            uniqueness: { scope: :com_timeline_id,
                          message: :already_tagged, }
end
