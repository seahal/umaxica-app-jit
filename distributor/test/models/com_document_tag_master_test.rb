# typed: false
# == Schema Information
#
# Table name: com_document_tag_masters
# Database name: publication
#
#  id        :bigint           not null, primary key
#  parent_id :bigint           not null
#
# Indexes
#
#  index_com_document_tag_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => com_document_tag_masters.id)
#

# frozen_string_literal: true

require "test_helper"

class ComDocumentTagMasterTest < ActiveSupport::TestCase
  include TreeableSharedTests

  test "has correct constants" do
    assert_equal 0, ComDocumentTagMaster::NOTHING
    assert_equal 1, ComDocumentTagMaster::LEGACY_NOTHING
  end

  test "can load nothing status from db" do
    status = ComDocumentTagMaster.find(ComDocumentTagMaster::NOTHING)

    assert_equal 0, status.id
  end

  test "treeable class is defined" do
    assert_equal ComDocumentTagMaster, treeable_class
  end

  private

  def treeable_class
    ComDocumentTagMaster
  end
end
