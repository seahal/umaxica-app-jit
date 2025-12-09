# == Schema Information
#
# Table name: app_documents
#
#  id               :uuid             not null, primary key
#  description      :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  app_document_status_id :string
#  parent_id        :uuid
#  prev_id          :uuid
#  staff_id         :uuid
#  succ_id          :uuid
#
class AppDocument < BusinessesRecord
  belongs_to :app_document_status, optional: true

  encrypts :title
  encrypts :description
end
