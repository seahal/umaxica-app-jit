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

  test "treeable class is defined" do
    assert_equal ComDocumentCategoryMaster, treeable_class
  end

  private

  def treeable_class
    ComDocumentCategoryMaster
  end
end
