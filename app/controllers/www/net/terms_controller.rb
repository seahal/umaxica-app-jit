# frozen_string_literal: true

module Net
  class TermsController < ApplicationController
    def show
      render plain: "kiyaku"
    end
  end
end
