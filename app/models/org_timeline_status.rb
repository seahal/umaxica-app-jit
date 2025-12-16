# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class OrgTimelineStatus < BusinessesRecord
  include UppercaseIdValidation

  has_many :org_timelines, dependent: :restrict_with_error, inverse_of: :org_timeline_status
end
