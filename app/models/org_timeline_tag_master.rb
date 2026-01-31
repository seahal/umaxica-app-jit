# == Schema Information
#
# Table name: org_timeline_tag_masters
# Database name: news
#
#  id        :integer          default(0), not null, primary key
#  parent_id :integer          default(0), not null
#
# Indexes
#
#  index_org_timeline_tag_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => org_timeline_tag_masters.id)
#

# frozen_string_literal: true

class OrgTimelineTagMaster < NewsRecord
  include Treeable

  belongs_to :parent,
             class_name: "OrgTimelineTagMaster",
             inverse_of: :children,
             optional: true
  has_many :children,
           class_name: "OrgTimelineTagMaster",
           foreign_key: :parent_id,
           inverse_of: :parent,
           dependent: :restrict_with_error
  has_many :org_timeline_tags, dependent: :restrict_with_error
  has_many :org_timelines, through: :org_timeline_tags
  self.primary_key = "id"

  validates :id, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  attribute :parent_id, default: 0

  validates :parent_id, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.tree_root_parent_value = 0

  def self.tree_root_parent_values
    [tree_root_parent_value, "NEYO", "none"].uniq
  end

  def name
    I18n.t("org_timeline_tags.%{id}", id: id)
  end

  def root?
    parent_id.zero?
  end
end
