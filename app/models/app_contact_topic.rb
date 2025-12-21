# frozen_string_literal: true

class AppContactTopic < GuestsRecord
  include ::PublicId
  belongs_to :app_contact
end
