# == Schema Information
#
# Table name: app_document_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class AppDocumentStatus < BusinessesRecord
  include UppercaseId
end
