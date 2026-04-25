# typed: false
# == Schema Information
#
# Table name: app_document_category_masters
# Database name: publication
#
#  id        :bigint           not null, primary key
#  parent_id :bigint           not null
#
# Indexes
#
#  index_app_document_category_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => app_document_category_masters.id)
#

# frozen_string_literal: true

require "test_helper"

class AppDocumentCategoryMasterTest < ActiveSupport::TestCase
  include TreeableSharedTests

  test "has correct constants" do
    assert_equal 0, AppDocumentCategoryMaster::NOTHING
    assert_equal 1, AppDocumentCategoryMaster::LEGACY_NOTHING
  end

  test "can load nothing status from db" do
    status = AppDocumentCategoryMaster.find(AppDocumentCategoryMaster::NOTHING)

    assert_equal 0, status.id
  end

  test "connects to publication database" do
    AppDocumentCategoryMaster.with_connection do |connection|
      assert_match(/^test_publication_db(_\d+)?$/, connection.select_value("SELECT current_database()"))
      assert connection.table_exists?("app_document_category_masters")
    end
  end

  test "treeable class is defined" do
    assert_equal AppDocumentCategoryMaster, treeable_class
  end

  private

  def treeable_class
    AppDocumentCategoryMaster
  end
end
