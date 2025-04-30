
module EmailAddress
  extend ActiveSupport::Concern

  included do
    validates :address, length: 3..255,
              format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
              uniqueness: { case_sensitive: false }
  end
end
