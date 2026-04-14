# typed: false
# == Schema Information
#
# Table name: org_document_tag_masters
# Database name: publication
#
#  id        :bigint           not null, primary key
#  parent_id :bigint           not null
#
# Indexes
#
#  index_org_document_tag_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => org_document_tag_masters.id)
#

# frozen_string_literal: true

require "test_helper"

class OrgDocumentTagMasterTest < ActiveSupport::TestCase
  include TreeableSharedTests

  test "treeable class is defined" do
    assert_equal OrgDocumentTagMaster, treeable_class
  end

  private

  def treeable_class
    OrgDocumentTagMaster
  end
end
