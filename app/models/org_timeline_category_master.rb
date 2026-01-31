# == Schema Information
#
# Table name: org_timeline_category_masters
# Database name: news
#
#  id        :integer          default(0), not null, primary key
#  parent_id :integer          default(0), not null
#
# Indexes
#
#  index_org_timeline_category_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => org_timeline_category_masters.id)
#

# frozen_string_literal: true

class OrgTimelineCategoryMaster < NewsRecord
  include Treeable

  belongs_to :parent,
             class_name: "OrgTimelineCategoryMaster",
             inverse_of: :children,
             optional: true
  has_many :children,
           class_name: "OrgTimelineCategoryMaster",
           foreign_key: :parent_id,
           inverse_of: :parent,
           dependent: :restrict_with_error
  has_many :org_timeline_categories,
           dependent: :restrict_with_error,
           inverse_of: :org_timeline_category_master
  has_many :org_timelines, through: :org_timeline_categories
  self.primary_key = "id"

  validates :id, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  attribute :parent_id, default: 0

  validates :parent_id, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.tree_root_parent_value = 0

  def self.tree_root_parent_values
    [tree_root_parent_value, "NEYO", "none"].uniq
  end

  def name
    I18n.t("org_timeline_categorys.%{id}", id: id)
  end

  def root?
    parent_id.zero?
  end
end
