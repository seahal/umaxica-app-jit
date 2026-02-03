# == Schema Information
#
# Table name: com_timeline_category_masters
# Database name: news
#
#  id        :bigint           not null, primary key
#  parent_id :bigint           not null
#
# Indexes
#
#  index_com_timeline_category_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_com_timeline_category_masters_parent  (parent_id => com_timeline_category_masters.id)
#

# frozen_string_literal: true

class ComTimelineCategoryMaster < NewsRecord
  include Treeable

  # Fixed IDs - do not modify these values
  NEYO = 1

  belongs_to :parent,
             class_name: "ComTimelineCategoryMaster",
             inverse_of: :children,
             optional: true
  has_many :children,
           class_name: "ComTimelineCategoryMaster",
           foreign_key: :parent_id,
           inverse_of: :parent,
           dependent: :restrict_with_error
  has_many :com_timeline_categories,
           dependent: :restrict_with_error,
           inverse_of: :com_timeline_category_master
  has_many :com_timelines, through: :com_timeline_categories
  self.primary_key = "id"

  attribute :parent_id, default: 0

  validates :parent_id, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.tree_root_parent_value = 0

  def name
    I18n.t("com_timeline_categorys.%{id}", id: id)
  end

  def root?
    parent_id.zero?
  end
end
