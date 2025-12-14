# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timelines
#
#  id               :uuid             not null, primary key
#  description      :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  app_timeline_status_id :string
#  parent_id        :uuid
#  prev_id          :uuid
#  staff_id         :uuid
#  succ_id          :uuid
#
class AppTimeline < BusinessesRecord
  belongs_to :app_timeline_status, optional: true

  include Timeline

  has_many :app_timeline_audits,
           class_name: "AppTimelineAudit",
           primary_key: "id",
           inverse_of: :app_timeline,
           dependent: :restrict_with_exception
end
