# == Schema Information
#
# Table name: org_document_tag_masters
#
#  id         :string(255)      not null, primary key
#  parent_id  :string(255)      default("none"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_org_document_tag_masters_on_parent_id  (parent_id)
#

# frozen_string_literal: true

require "test_helper"

class OrgDocumentTagMasterTest < ActiveSupport::TestCase
  include TreeableSharedTests

  private

  def treeable_class
    OrgDocumentTagMaster
  end
end
