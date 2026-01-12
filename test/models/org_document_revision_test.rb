# == Schema Information
#
# Table name: org_document_revisions
#
#  id              :uuid             not null, primary key
#  org_document_id :uuid             not null
#  permalink       :string(200)      not null
#  response_mode   :string           not null
#  redirect_url    :string
#  title           :string
#  description     :string
#  body            :text
#  published_at    :datetime         not null
#  expires_at      :datetime         not null
#  edited_by_type  :string
#  edited_by_id    :integer
#  public_id       :string(255)      default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_org_document_revisions_on_org_document_id                 (org_document_id)
#  index_org_document_revisions_on_org_document_id_and_created_at  (org_document_id,created_at)
#  index_org_document_revisions_on_public_id                       (public_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class OrgDocumentRevisionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
