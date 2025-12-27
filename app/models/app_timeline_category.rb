# == Schema Information
#
# Table name: app_timeline_categories
#
#  id                              :uuid             not null, primary key
#  app_timeline_id                 :uuid             not null
#  app_timeline_category_master_id :string(255)      not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
# Indexes
#
#  idx_on_app_timeline_category_master_id_d1179f51ba  (app_timeline_category_master_id)
#  index_app_timeline_categories_unique               (app_timeline_id) UNIQUE
#

# frozen_string_literal: true

class AppTimelineCategory < NewsRecord
  belongs_to :app_timeline, inverse_of: :category
  belongs_to :app_timeline_category_master,
             primary_key: :id,
             inverse_of: :app_timeline_categories

  validates :app_timeline_id, uniqueness: true
  validates :app_timeline_category_master_id, length: { maximum: 255 }
end
