# == Schema Information
#
# Table name: app_timeline_versions
#
#  id              :uuid             not null, primary key
#  app_timeline_id :uuid             not null
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
#  index_app_timeline_versions_on_app_timeline_id                 (app_timeline_id)
#  index_app_timeline_versions_on_app_timeline_id_and_created_at  (app_timeline_id,created_at)
#

class AppTimelineVersion < TimelineVersionBase
  belongs_to :app_timeline
end
