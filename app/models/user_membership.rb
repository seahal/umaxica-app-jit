# frozen_string_literal: true

# == Schema Information
#
# Table name: user_memberships
# Database name: principal
#
#  id           :bigint           not null, primary key
#  joined_at    :datetime         not null
#  left_at      :datetime         default(-Infinity), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#  workspace_id :uuid             not null
#
# Indexes
#
#  index_user_memberships_on_user_id_and_workspace_id  (user_id,workspace_id) UNIQUE
#  index_user_memberships_on_workspace_id              (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class UserMembership < PrincipalRecord
  belongs_to :user, inverse_of: :user_memberships
  belongs_to :workspace, inverse_of: :user_memberships

  validates :user_id, uniqueness: { scope: :workspace_id }
end
