# == Schema Information
#
# Table name: app_timeline_tags
# Database name: news
#
#  id                         :bigint           not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  app_timeline_id            :bigint           not null
#  app_timeline_tag_master_id :bigint           default(0), not null
#
# Indexes
#
#  idx_app_timeline_tags_on_master_and_timeline  (app_timeline_tag_master_id,app_timeline_id) UNIQUE
#  index_app_timeline_tags_on_app_timeline_id    (app_timeline_id)
#
# Foreign Keys
#
#  fk_app_timeline_tags_on_app_timeline_tag_master_id  (app_timeline_tag_master_id => app_timeline_tag_masters.id)
#  fk_rails_...                                        (app_timeline_id => app_timelines.id) ON DELETE => cascade
#

# frozen_string_literal: true

class AppTimelineTag < NewsRecord
  belongs_to :app_timeline, inverse_of: :app_timeline_tags
  belongs_to :app_timeline_tag_master,
             primary_key: :id,
             inverse_of: :app_timeline_tags

  validates :app_timeline_tag_master_id,
            uniqueness: { scope: :app_timeline_id,
                          message: :already_tagged, }
end
