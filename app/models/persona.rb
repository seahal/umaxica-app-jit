# == Schema Information
#
# Table name: personas
#
#  id            :uuid             not null, primary key
#  avatar        :jsonb
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  identifier_id :uuid
#
class Persona < SpecialitiesRecord
  mount_uploader :avatar, AvatarUploader
end
