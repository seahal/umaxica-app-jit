# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_bulletins
# Database name: principal
#
#  id         :bigint           not null, primary key
#  body       :text
#  read_at    :datetime
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  public_id  :string(21)       not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_bulletins_on_public_id  (public_id) UNIQUE
#  index_user_bulletins_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class UserBulletin < PrincipalRecord
  include PublicId

  belongs_to :user, inverse_of: :user_bulletins

  scope :unread, -> { where(read_at: nil) }
  scope :oldest_first, -> { order(created_at: :asc) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end
end
