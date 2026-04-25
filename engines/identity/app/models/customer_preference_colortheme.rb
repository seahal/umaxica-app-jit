# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_preference_colorthemes
# Database name: guest
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :bigint           not null
#  preference_id :bigint           not null
#
# Indexes
#
#  index_customer_preference_colorthemes_on_option_id      (option_id)
#  index_customer_preference_colorthemes_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (option_id => customer_preference_colortheme_options.id)
#  fk_rails_...  (preference_id => customer_preferences.id)
#
class CustomerPreferenceColortheme < GuestRecord
  belongs_to :preference, class_name: "CustomerPreference", inverse_of: :customer_preference_colortheme
  belongs_to :option,
             class_name: "CustomerPreferenceColorthemeOption",
             inverse_of: :customer_preference_colorthemes,
             optional: true

  validates :preference_id, uniqueness: true
  validates :option_id, presence: true

  before_validation :set_option_id

  private

  def set_option_id
    self.option_id ||= CustomerPreferenceColorthemeOption::SYSTEM
  end
end
