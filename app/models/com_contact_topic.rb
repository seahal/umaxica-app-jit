class ComContactTopic < GuestsRecord
  include ::PublicId

  belongs_to :com_contact
end
