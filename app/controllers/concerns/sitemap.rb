# typed: false
# frozen_string_literal: true

module Sitemap
  extend ActiveSupport::Concern

  private

  def show_xml
    render formats: :xml
  end

  def show_json
    render json: { urls: sitemap_urls }
  end

  def sitemap_urls
    []
  end
end
