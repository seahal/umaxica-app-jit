# typed: false
# == Schema Information
#
# Table name: user_member_impersonations
# Database name: principal
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  member_id  :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_member_impersonations_on_member_id              (member_id)
#  index_user_member_impersonations_on_user_id                (user_id)
#  index_user_member_impersonations_on_user_id_and_member_id  (user_id,member_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#  fk_rails_...  (user_id => users.id)
#

# frozen_string_literal: true

class UserMemberImpersonation < PrincipalRecord
  belongs_to :user, inverse_of: :user_member_impersonations
  belongs_to :member, inverse_of: :user_member_impersonations

  validates :member_id, uniqueness: { scope: :user_id }
end
