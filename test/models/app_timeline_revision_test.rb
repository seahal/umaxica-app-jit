# == Schema Information
#
# Table name: app_timeline_revisions
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
#  app_timeline_id :bigint           not null
#  edited_by_id    :bigint
#  public_id       :string(255)      default(""), not null
#
# Indexes
#
#  index_app_timeline_revisions_on_app_timeline_id_and_created_at  (app_timeline_id,created_at)
#  index_app_timeline_revisions_on_public_id                       (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (app_timeline_id => app_timelines.id) ON DELETE => cascade
#

# frozen_string_literal: true

require "test_helper"

class AppTimelineRevisionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
