# == Schema Information
#
# Table name: com_document_versions
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
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_com_document_versions_on_com_document_id                 (com_document_id)
#  index_com_document_versions_on_com_document_id_and_created_at  (com_document_id,created_at)
#

class ComDocumentVersion < DocumentVersionBase
  belongs_to :com_document
end
