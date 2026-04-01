# typed: false
# == Schema Information
#
# Table name: com_timeline_revisions
# Database name: publication
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
#  com_timeline_id :bigint           not null
#  edited_by_id    :bigint
#  public_id       :string(255)      default(""), not null
#
# Indexes
#
#  index_com_timeline_revisions_on_com_timeline_id_and_created_at  (com_timeline_id,created_at)
#  index_com_timeline_revisions_on_edited_by_id                    (edited_by_id)
#  index_com_timeline_revisions_on_public_id                       (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (com_timeline_id => com_timelines.id) ON DELETE => cascade
#

# frozen_string_literal: true

require "test_helper"

class ComTimelineRevisionTest < ActiveSupport::TestCase
  test "class is defined" do
    assert_equal "ComTimelineRevision", ComTimelineRevision.name
  end
end
