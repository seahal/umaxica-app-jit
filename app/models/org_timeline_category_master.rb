# typed: false
# == Schema Information
#
# Table name: org_timeline_category_masters
# Database name: publication
#
#  id        :bigint           not null, primary key
#  parent_id :bigint           not null
#
# Indexes
#
#  index_org_timeline_category_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_org_timeline_category_masters_parent  (parent_id => org_timeline_category_masters.id)
#

# frozen_string_literal: true

class OrgTimelineCategoryMaster < PublicationRecord
  include Treeable

  # Fixed IDs - do not modify these values
  NOTHING = 1
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

  attribute :parent_id, default: 0

  validates :parent_id, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.tree_root_parent_value = 0

  def name
    I18n.t("org_timeline_categories.%{id}", id: id)
  end

  def root?
    parent_id.zero?
  end
end
