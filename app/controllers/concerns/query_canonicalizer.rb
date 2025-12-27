# frozen_string_literal: true

# app/controllers/concerns/query_canonicalizer.rb
module QueryCanonicalizer
  extend ActiveSupport::Concern

  DEFAULTS = {
    "ri" => "jp",
    "lx" => "ja",
    "ct" => "sy",
    "tz" => "jst",
  }.freeze

  private

  # Value normalization rules
  # - lx: "ja" if not "ja"/"en"
  # - ri: "jp" if not "jp"/"us" or empty
  # - tz: "jst" if not "jst"/"utc"
  # - ct: "sy" if not "sy"/"mu"/"dr"
  def normalize_params(raw)
    keys = DEFAULTS.keys
    src = raw.slice(*keys)

    lx =
      case (src["lx"].presence)
      when "ja", "en" then src["lx"]
      else "ja"
      end

    ri =
      case (src["ri"].presence)
      when "jp", "us" then src["ri"]
      else "jp"
      end

    tz =
      case (src["tz"].presence)
      when "jst", "utc" then src["tz"]
      else "jst"
      end

    ct =
      case (src["ct"].presence)
      when "sy", "mu", "dr" then src["ct"]
      else "sy"
      end

    { "lx" => lx, "ri" => ri, "tz" => tz, "ct" => ct }
  end

  def canonicalize_query_params
    # Do not touch anything other than GET/HEAD (Redirecting POSTs is dangerous)
    return unless request.get? || request.head?

    # Normalize parameter values
    expected = normalize_params(request.query_parameters)

    # Build canonical (sorted) query string
    canonical = expected.sort_by { |k, _| k }.to_h
    canonical_query = Rack::Utils.build_query(canonical)

    # Build current query string from actual query parameters
    # Filter to only include DEFAULTS keys while preserving original order
    current_filtered = {}
    request.query_parameters.each do |key, value|
      current_filtered[key] = value if DEFAULTS.key?(key)
    end
    current_query = Rack::Utils.build_query(current_filtered)

    # Do nothing if "meaning (set of target key values)" already matches and order is normalized (loop prevention)
    # NOTE: This intentionally adds default parameters even if not originally present.
    # This is the desired behavior to ensure consistent URLs with normalized parameters.
    # The loop prevention check prevents infinite redirects.
    return if current_query == canonical_query

    # Stabilize order (alphabetical) and 302 to relative URL
    path = request.path
    location = canonical_query.empty? ? path : "#{path}?#{canonical_query}"

    redirect_to location,
                allow_other_host: false,
                status: :found # :moved_permanently (301) if you want to fix it in production
  end
end

# Issues
# - If query parameters are default values, can we remove the query?
# - How to handle boundary values (empty strings or nil)?
#   -> Currently, empty strings or nil are normalized to default values, so they are effectively removed from the query
# - Should language/region information be included in the URL from the perspective of multilingual/multi-region support?
#   -> Ensure URL does not change depending on the viewer.
#     -> This is important, but I decided to abandon it because it conflicts with not displaying fixed values.
# - How about reflecting JWT cookie values in the URL?
# Priority param > cookie > default
# Parameter settings are slightly different between global and region.
# Do not include in URL if it is a fixed value.
# - Which parameters should be included in the URL?
#  - ri: language => This is required in the global environment, but in the
#    region environment it is expressed in the subdomain.
