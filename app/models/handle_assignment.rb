# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_assignments
#
#  id                          :string           not null, primary key
#  avatar_id                   :string           not null
#  handle_id                   :string           not null
#  valid_from                  :timestamptz      not null
#  valid_to                    :timestamptz      default("infinity"), not null
#  handle_assignment_status_id :string
#  assigned_by_actor_id        :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_handle_assignments_on_avatar_id                    (avatar_id) UNIQUE
#  index_handle_assignments_on_avatar_id_and_valid_from     (avatar_id,valid_from)
#  index_handle_assignments_on_handle_assignment_status_id  (handle_assignment_status_id)
#  index_handle_assignments_on_handle_id                    (handle_id) UNIQUE
#  index_handle_assignments_on_handle_id_and_valid_from     (handle_id,valid_from)
#

class HandleAssignment < IdentitiesRecord
  include StringPrimaryKey

  belongs_to :avatar
  belongs_to :handle
  belongs_to :handle_assignment_status, optional: true

  validates :avatar_id, uniqueness: true
  validates :handle_id, uniqueness: true
  validates :valid_from, presence: true
end
