# frozen_string_literal: true

require "pagy"
# require "pagy/extras/overflow"
# require "pagy/extras/i18n"

module PagyConfig
  extend ActiveSupport::Concern

  included do
    # Set default Pagy variables
    Pagy::DEFAULT[:limit] = 20
    # Pagy::DEFAULT[:overflow] = :last_page
  end
end
