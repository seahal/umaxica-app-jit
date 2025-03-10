# frozen_string_literal: true

module Org
  class TermsController < ApplicationController
    def show
      render plain: "kiyaku data"
    end
  end
end
