# == Schema Information
#
# Table name: org_document_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class OrgDocumentStatus < BusinessesRecord
  include UppercaseId
end
