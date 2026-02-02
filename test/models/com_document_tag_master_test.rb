# == Schema Information
#
# Table name: com_document_tag_masters
# Database name: document
#
#  id        :bigint           not null, primary key
#  code      :citext           not null
#  parent_id :bigint           not null
#
# Indexes
#
#  index_com_document_tag_masters_on_code       (code) UNIQUE
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

  private

  def treeable_class
    ComDocumentTagMaster
  end
end
