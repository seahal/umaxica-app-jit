# == Schema Information
#
# Table name: app_document_category_masters
# Database name: document
#
#  id        :bigint           not null, primary key
#  code      :citext           not null
#  parent_id :bigint           not null
#
# Indexes
#
#  index_app_document_category_masters_on_code       (code) UNIQUE
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

  private

  def treeable_class
    AppDocumentCategoryMaster
  end
end
