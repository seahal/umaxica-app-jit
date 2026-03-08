# typed: false
# frozen_string_literal: true

module Sitemap
  extend ActiveSupport::Concern

  included do
    begin
      skip_before_action :canonicalize_query_params
    rescue ArgumentError
      # Callback doesn't exist, ignore
    end
    public_strict! if respond_to?(:public_strict!)
  end

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
