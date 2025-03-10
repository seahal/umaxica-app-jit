# frozen_string_literal: true

module Net
  class RootsController < ApplicationController
    def index
      # This screen is not displayed in the production environment.
      redirect_to "https://umaxica.net", allow_other_host: true unless Rails.env.development?
    end
  end
end
