# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timelines
# Database name: news
#
#  id                 :bigint           not null, primary key
#  expires_at         :datetime         default(Infinity), not null
#  lock_version       :integer          default(0), not null
#  position           :integer          default(0), not null
#  published_at       :datetime         default(Infinity), not null
#  redirect_url       :string
#  response_mode      :string           default("html"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  latest_revision_id :bigint
#  latest_version_id  :bigint
#  slug_id            :string(32)       default(""), not null
#  status_id          :bigint           default(1), not null
#
# Indexes
#
#  index_app_timelines_on_latest_revision_id           (latest_revision_id) UNIQUE
#  index_app_timelines_on_latest_version_id            (latest_version_id) UNIQUE
#  index_app_timelines_on_published_at_and_expires_at  (published_at,expires_at)
#  index_app_timelines_on_slug_id                      (slug_id)
#  index_app_timelines_on_status_id                    (status_id)
#
# Foreign Keys
#
#  fk_app_timelines_on_status_id  (status_id => app_timeline_statuses.id)
#  fk_rails_...                   (latest_revision_id => app_timeline_revisions.id) ON DELETE => nullify
#  fk_rails_...                   (latest_version_id => app_timeline_versions.id) ON DELETE => nullify
#

class AppTimeline < NewsRecord
  include ::SlugId
  include Timeline

  attribute :status_id, default: AppTimelineStatus::NEYO

  validates :latest_version_id, :latest_revision_id, uniqueness: { allow_nil: true }

  belongs_to :app_timeline_status,
             class_name: "AppTimelineStatus",
             foreign_key: :status_id,
             inverse_of: :app_timelines

  validates :latest_version_id, :latest_revision_id, uniqueness: { allow_nil: true }

  belongs_to :latest_version_record,
             class_name: "AppTimelineVersion",
             foreign_key: :latest_version_id,
             inverse_of: :latest_timeline,
             optional: true
  validates :latest_version_id, :latest_revision_id, uniqueness: { allow_nil: true }

  belongs_to :latest_revision_record,
             class_name: "AppTimelineRevision",
             foreign_key: :latest_revision_id,
             inverse_of: :latest_timeline,
             optional: true

  has_many :app_timeline_versions, dependent: :delete_all, inverse_of: :app_timeline
  has_many :app_timeline_revisions, dependent: :delete_all, inverse_of: :app_timeline
  has_many :app_timeline_behaviors,
           -> { where(subject_type: "AppTimeline") },
           class_name: "AppTimelineBehavior",
           foreign_key: :subject_id,
           inverse_of: :app_timeline,
           dependent: :delete_all
  has_many :app_timeline_tags, dependent: :delete_all, inverse_of: :app_timeline
  has_many :tag_masters,
           through: :app_timeline_tags,
           source: :app_timeline_tag_master
  has_one :category,
          class_name: "AppTimelineCategory",
          dependent: :delete,
          inverse_of: :app_timeline
  has_one :category_master,
          through: :category,
          source: :app_timeline_category_master

  def latest_version
    app_timeline_versions.order(created_at: :desc).first!
  end
end
