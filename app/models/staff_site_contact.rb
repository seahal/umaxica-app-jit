class StaffSiteContact < GuestsRecord
  before_save { self.email_address&.downcase! }
  before_save { self.telephone_number&.downcase! }
end
