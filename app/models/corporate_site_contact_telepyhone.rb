class CorporateSiteContactTelepyhone < GuestsRecord
  belongs_to :corporate_site_contact
  before_save { self.telephone_number&.downcase! }
  encrypts :telephone_number, downcase: true, deterministic: true
end
