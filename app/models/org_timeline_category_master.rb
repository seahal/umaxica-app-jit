# == Schema Information
#
# Table name: org_timeline_category_masters
#
#  id         :string(255)      not null, primary key
#  parent_id  :string(255)      default("none"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_org_timeline_category_masters_on_parent_id  (parent_id)
#

# frozen_string_literal: true

class OrgTimelineCategoryMaster < NewsRecord
  include UppercaseId
  include ::CatTagMaster

  self.primary_key = "id"

  attribute :parent_id, default: "NEYO"

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

  validates :id, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :parent_id, presence: true, length: { maximum: 255 }

  def name
    I18n.t("org_timeline_categorys.%{id}", id: id)
  end

  def root?
    parent_id == "NEYO"
  end
end
