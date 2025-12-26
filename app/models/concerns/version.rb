module Version
  extend ActiveSupport::Concern

  included do
    encrypts :title
    encrypts :body
    encrypts :description

    validates :public_id, uniqueness: true, length: { maximum: 21 }
  end
end
