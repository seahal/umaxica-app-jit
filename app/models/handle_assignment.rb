# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_assignments
# Database name: avatar
#
#  id                          :string           not null, primary key
#  valid_from                  :timestamptz      not null
#  valid_to                    :timestamptz      default(Infinity), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  assigned_by_actor_id        :string
#  avatar_id                   :string           not null
#  handle_assignment_status_id :string
#  handle_id                   :string           not null
#
# Indexes
#
#  index_handle_assignments_on_avatar_id                    (avatar_id) UNIQUE WHERE (valid_to = 'infinity'::timestamp with time zone)
#  index_handle_assignments_on_avatar_id_and_valid_from     (avatar_id,valid_from DESC)
#  index_handle_assignments_on_handle_assignment_status_id  (handle_assignment_status_id)
#  index_handle_assignments_on_handle_id                    (handle_id) UNIQUE WHERE (valid_to = 'infinity'::timestamp with time zone)
#  index_handle_assignments_on_handle_id_and_valid_from     (handle_id,valid_from DESC)
#
# Foreign Keys
#
#  fk_rails_...  (avatar_id => avatars.id)
#  fk_rails_...  (handle_assignment_status_id => handle_assignment_statuses.id)
#  fk_rails_...  (handle_id => handles.id)
#

class HandleAssignment < AvatarRecord
  include UuidV7PrimaryKey

  belongs_to :avatar
  belongs_to :handle
  belongs_to :handle_assignment_status, optional: true

  validates :avatar_id, uniqueness: true
  validates :handle_id, uniqueness: true
  validates :valid_from, presence: true
end
