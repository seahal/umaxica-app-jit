# typed: false
# frozen_string_literal: true

module Sitemap
  extend ActiveSupport::Concern

  BROWSER_CACHE_TTL = 5.minutes
  CDN_CACHE_TTL = 10.minutes

  private

  def show_xml
    response.set_header(
      "Cache-Control",
      "public, max-age=#{BROWSER_CACHE_TTL.to_i}, s-maxage=#{CDN_CACHE_TTL.to_i}",
    )
    response.set_header("Surrogate-Control", "max-age=#{CDN_CACHE_TTL.to_i}")
    render formats: :xml
  end

  def show_json
    render json: { urls: sitemap_urls }
  end

  def sitemap_urls
    []
  end

  def sitemap_entry(loc:, lastmod: nil, changefreq: nil, priority: nil)
    entry = { loc: loc }
    entry[:lastmod] = lastmod.iso8601 if lastmod.respond_to?(:iso8601)
    entry[:changefreq] = changefreq if changefreq
    entry[:priority] = priority if priority
    entry
  end
end
