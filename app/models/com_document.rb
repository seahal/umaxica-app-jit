# == Schema Information
#
# Table name: com_documents
#
#  id            :uuid             not null, primary key
#  permalink     :string(200)      not null
#  response_mode :string           default("html"), not null
#  redirect_url  :string
#  revision_key  :string           not null
#  published_at  :datetime         default("infinity"), not null
#  expires_at    :datetime         default("infinity"), not null
#  position      :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_com_documents_on_permalink                    (permalink) UNIQUE
#  index_com_documents_on_published_at_and_expires_at  (published_at,expires_at)
#

class ComDocument < DocumentBase
  has_many :com_document_versions, dependent: :delete_all
  has_many :com_document_audits,
           -> { where(subject_type: "ComDocument") },
           class_name: "ComDocumentAudit",
           foreign_key: :subject_id,
           inverse_of: :com_document,
           dependent: :delete_all

  def latest_version
    com_document_versions.order(created_at: :desc).first!
  end
end
