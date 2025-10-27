class CorporateSiteContactEmail < GuestsRecord
  belongs_to :corporate_site_contact
  before_save { self.email_address&.downcase! }
  encrypts :email_address, downcase: true, deterministic: true
end
