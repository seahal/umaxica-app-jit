class CorporateSiteContactTopic < GuestsRecord
  belongs_to :corporate_site_contact

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true
end
