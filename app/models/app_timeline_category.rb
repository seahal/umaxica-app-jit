# == Schema Information
#
# Table name: app_timeline_categories
# Database name: news
#
#  id                              :bigint           not null, primary key
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  app_timeline_category_master_id :bigint           default(0), not null
#  app_timeline_id                 :bigint           not null
#
# Indexes
#
#  idx_on_app_timeline_category_master_id_d1179f51ba  (app_timeline_category_master_id)
#  index_app_timeline_categories_unique               (app_timeline_id) UNIQUE
#
# Foreign Keys
#
#  fk_app_timeline_categories_on_app_timeline_category_master_id  (app_timeline_category_master_id => app_timeline_category_masters.id)
#  fk_rails_...                                                   (app_timeline_id => app_timelines.id) ON DELETE => cascade
#

# frozen_string_literal: true

class AppTimelineCategory < NewsRecord
  belongs_to :app_timeline, inverse_of: :category
  belongs_to :app_timeline_category_master,
             primary_key: :id,
             inverse_of: :app_timeline_categories

  validates :app_timeline_id, uniqueness: true
end
