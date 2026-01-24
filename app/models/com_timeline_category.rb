# == Schema Information
#
# Table name: com_timeline_categories
# Database name: news
#
#  id                              :uuid             not null, primary key
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  com_timeline_category_master_id :string(255)      not null
#  com_timeline_id                 :uuid             not null
#
# Indexes
#
#  idx_on_com_timeline_category_master_id_3ab8427d3a  (com_timeline_category_master_id)
#  index_com_timeline_categories_unique               (com_timeline_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (com_timeline_category_master_id => com_timeline_category_masters.id)
#  fk_rails_...  (com_timeline_id => com_timelines.id) ON DELETE => cascade
#

# frozen_string_literal: true

class ComTimelineCategory < NewsRecord
  belongs_to :com_timeline, inverse_of: :category
  belongs_to :com_timeline_category_master,
             primary_key: :id,
             inverse_of: :com_timeline_categories

  validates :com_timeline_id, uniqueness: true
  validates :com_timeline_category_master_id, length: { maximum: 255 }
end
