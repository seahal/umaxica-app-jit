# == Schema Information
#
# Table name: org_timeline_revisions
# Database name: news
#
#  id              :bigint           not null, primary key
#  body            :text
#  description     :string
#  edited_by_type  :string
#  expires_at      :datetime         not null
#  permalink       :string(200)      not null
#  published_at    :datetime         not null
#  redirect_url    :string
#  response_mode   :string           not null
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  edited_by_id    :bigint
#  org_timeline_id :bigint           not null
#  public_id       :string(255)      default(""), not null
#
# Indexes
#
#  index_org_timeline_revisions_on_org_timeline_id                 (org_timeline_id)
#  index_org_timeline_revisions_on_org_timeline_id_and_created_at  (org_timeline_id,created_at)
#  index_org_timeline_revisions_on_public_id                       (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (org_timeline_id => org_timelines.id)
#

# frozen_string_literal: true

require "test_helper"

class OrgTimelineRevisionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
