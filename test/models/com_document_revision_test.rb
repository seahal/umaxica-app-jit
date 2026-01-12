# == Schema Information
#
# Table name: com_document_revisions
#
#  id              :uuid             not null, primary key
#  com_document_id :uuid             not null
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
#  index_com_document_revisions_on_com_document_id                 (com_document_id)
#  index_com_document_revisions_on_com_document_id_and_created_at  (com_document_id,created_at)
#  index_com_document_revisions_on_public_id                       (public_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class ComDocumentRevisionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
