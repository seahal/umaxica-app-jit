# == Schema Information
#
# Table name: post_versions
#
#  id             :uuid             not null, primary key
#  post_id        :string           not null
#  permalink      :string(200)      not null
#  response_mode  :string           not null
#  redirect_url   :string
#  title          :string
#  description    :string
#  body           :text
#  published_at   :datetime         not null
#  expires_at     :datetime         not null
#  edited_by_type :string
#  edited_by_id   :string
#  public_id      :string           default(""), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_post_versions_on_post_id_and_created_at  (post_id,created_at)
#  index_post_versions_on_public_id               (public_id) UNIQUE
#

# frozen_string_literal: true

class PostVersion < IdentitiesRecord
  include ::Version
  include ::PublicId

  belongs_to :post, inverse_of: :post_versions

  validates :permalink, presence: true, length: { maximum: 200 }
  validates :response_mode, presence: true
  validates :published_at, presence: true
  validates :expires_at, presence: true
end
