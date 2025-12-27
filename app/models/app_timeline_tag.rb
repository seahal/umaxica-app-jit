# == Schema Information
#
# Table name: app_timeline_tags
#
#  id                         :uuid             not null, primary key
#  app_timeline_id            :uuid             not null
#  app_timeline_tag_master_id :string(255)      not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_app_timeline_tags_on_app_timeline_tag_master_id  (app_timeline_tag_master_id)
#  index_app_timeline_tags_unique                         (app_timeline_id,app_timeline_tag_master_id) UNIQUE
#

# frozen_string_literal: true

class AppTimelineTag < NewsRecord
  belongs_to :app_timeline, inverse_of: :app_timeline_tags
  belongs_to :app_timeline_tag_master,
             primary_key: :id,
             inverse_of: :app_timeline_tags

  validates :app_timeline_tag_master_id,
            length: { maximum: 255 },
            uniqueness: { scope: :app_timeline_id,
                          message: :already_tagged, }
end
