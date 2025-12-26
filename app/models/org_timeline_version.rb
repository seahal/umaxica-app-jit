# == Schema Information
#
# Table name: org_timeline_versions
#
#  id              :uuid             not null, primary key
#  org_timeline_id :uuid             not null
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
#  index_org_timeline_versions_on_org_timeline_id                 (org_timeline_id)
#  index_org_timeline_versions_on_org_timeline_id_and_created_at  (org_timeline_id,created_at)
#

class OrgTimelineVersion < TimelineVersionBase
  belongs_to :org_timeline
end
