# == Schema Information
#
# Table name: org_document_category_masters
#
#  id         :string(255)      not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :string(255)      default("none"), not null
#
# Indexes
#
#  index_org_document_category_masters_on_parent_id  (parent_id)
#

# frozen_string_literal: true

require "test_helper"

class OrgDocumentCategoryMasterTest < ActiveSupport::TestCase
  include TreeableSharedTests

  private

  def treeable_class
    OrgDocumentCategoryMaster
  end
end
