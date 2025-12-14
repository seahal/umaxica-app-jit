# frozen_string_literal: true

# == Schema Information
#
# Table name: com_documents
#
#  id               :uuid             not null, primary key
#  description      :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  com_document_status_id :string
#  parent_id        :uuid
#  prev_id          :uuid
#  staff_id         :uuid
#  succ_id          :uuid
#
class ComDocument < BusinessesRecord
  belongs_to :com_document_status, optional: true

  include Document

  encrypts :title
  encrypts :description

  has_many :com_document_audits,
           class_name: "ComDocumentAudit",
           primary_key: "id",
           inverse_of: :com_document,
           dependent: :restrict_with_exception
end
