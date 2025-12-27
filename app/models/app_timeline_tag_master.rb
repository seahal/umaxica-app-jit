# == Schema Information
#
# Table name: app_timeline_tag_masters
#
#  id         :string(255)      not null, primary key
#  parent_id  :string(255)      default("none"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_app_timeline_tag_masters_on_parent_id  (parent_id)
#

# frozen_string_literal: true

class AppTimelineTagMaster < NewsRecord
  self.primary_key = "id"

  belongs_to :parent,
             class_name: "AppTimelineTagMaster",
             inverse_of: :children,
             optional: true

  has_many :children,
           class_name: "AppTimelineTagMaster",
           foreign_key: :parent_id,
           inverse_of: :parent,
           dependent: :restrict_with_error

  has_many :app_timeline_tags, dependent: :restrict_with_error
  has_many :app_timelines, through: :app_timeline_tags

  validates :id, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :parent_id, presence: true, length: { maximum: 255 }

  def name
    I18n.t("app_timeline_tags.%{id}", id: id)
  end

  def root?
    parent_id == "none"
  end
end
