# == Schema Information
#
# Table name: com_document_category_masters
# Database name: document
#
#  id        :integer          default(0), not null, primary key
#  parent_id :integer          default(0), not null
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

  private

  def treeable_class
    ComDocumentCategoryMaster
  end
end
