# == Schema Information
#
# Table name: app_timeline_revisions
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
#  public_id       :string(255)      default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_app_timeline_revisions_on_app_timeline_id                 (app_timeline_id)
#  index_app_timeline_revisions_on_app_timeline_id_and_created_at  (app_timeline_id,created_at)
#  index_app_timeline_revisions_on_public_id                       (public_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class AppTimelineRevisionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
