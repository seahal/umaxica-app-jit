# == Schema Information
#
# Table name: app_document_revisions
# Database name: document
#
#  id              :uuid             not null, primary key
#  body            :text
#  description     :string
#  edited_by_type  :string
#  expires_at      :datetime         not null
#  permalink       :string(200)      not null
#  published_at    :datetime         not null
#  redirect_url    :string
#  response_mode   :string           not null
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  app_document_id :uuid             not null
#  edited_by_id    :bigint
#  public_id       :string(255)      default(""), not null
#
# Indexes
#
#  index_app_document_revisions_on_app_document_id                 (app_document_id)
#  index_app_document_revisions_on_app_document_id_and_created_at  (app_document_id,created_at)
#  index_app_document_revisions_on_public_id                       (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (app_document_id => app_documents.id)
#

# frozen_string_literal: true

require "test_helper"

class AppDocumentRevisionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
