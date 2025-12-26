# == Schema Information
#
# Table name: com_document_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class ComDocumentStatus < BusinessesRecord
  include UppercaseId
end
