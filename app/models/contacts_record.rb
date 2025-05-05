class ContactsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :contact, reading: :contact_replica }
end
