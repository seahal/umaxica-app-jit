# == Schema Information
#
# Table name: app_document_category_masters
#
#  id         :string(255)      not null, primary key
#  parent_id  :string(255)      default("NEYO"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_app_document_category_masters_on_parent_id  (parent_id)
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
