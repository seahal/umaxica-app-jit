# typed: false
# == Schema Information
#
# Table name: com_document_category_masters
# Database name: document
#
#  id        :bigint           not null, primary key
#  parent_id :bigint           not null
#
# Indexes
#
#  index_com_document_category_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => com_document_category_masters.id)
#

# frozen_string_literal: true

require "test_helper"

class ComDocumentCategoryMasterTest < ActiveSupport::TestCase
  include TreeableSharedTests

  test "has correct constants" do
    assert_equal 0, ComDocumentCategoryMaster::NOTHING
    assert_equal 1, ComDocumentCategoryMaster::LEGACY_NOTHING
  end

  test "can load nothing status from db" do
    status = ComDocumentCategoryMaster.find(ComDocumentCategoryMaster::NOTHING)

    assert_equal 0, status.id
  end

  test "treeable class is defined" do
    assert_equal ComDocumentCategoryMaster, treeable_class
  end

  private

  def treeable_class
    ComDocumentCategoryMaster
  end
end
