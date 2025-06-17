module Www::App
  class InquiriesController < ApplicationController
    include ::Cloudflare
    include ::Rotp
    # include ::Common
    # include ::Memorize

    def new
      @service_site_contact = ServiceSiteContact.new
    end

    def create
    end

    def edit
    end

    def update
    end

    def show
    end
  end
end