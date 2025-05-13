# == Schema Information
#
# Table name: personas
#
#  id            :binary           not null, primary key
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  identifier_id :binary
#
class Persona < SpecialitiesRecord
  mount_uploader :avatar, AvatarUploader
end
