# app/controllers/concerns/query_canonicalizer.rb
module QueryCanonicalizer
  extend ActiveSupport::Concern

  DEFAULTS = {
    "ri" => "jp",
    "lx" => "ja",
    "ct" => "sy",
    "tz" => "jst"
  }.freeze

  private

  # 値の正規化規則
  # - lx: "ja"/"en" 以外は "ja"
  # - ri: "jp"/"us" 以外や空は "jp"
  # - tz: "jst"/"utc" 以外は "jst"
  # - ct: "sy"/"mu"/"dr" 以外は "sy"
  def normalize_params(raw)
    keys = DEFAULTS.keys
    src = raw.slice(*keys)

    lx = case (src["lx"].presence)
    when "ja", "en" then src["lx"]
    else "ja"
    end

    ri = case (src["ri"].presence)
    when "jp", "us" then src["ri"]
    else "jp"
    end

    tz = case (src["tz"].presence)
    when "jst", "utc" then src["tz"]
    else "jst"
    end

    ct = case (src["ct"].presence)
    when "sy", "mu", "dr" then src["ct"]
    else "sy"
    end

    { "lx" => lx, "ri" => ri, "tz" => tz, "ct" => ct }
  end

  def canonicalize_query_params
    # GET/HEAD 以外は触らない（POST系をリダイレクトすると危険）
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

    # 既に"意味（対象キーの値集合）"が一致し、順序も正規化されていれば何もしない（ループ防止）
    # NOTE: This intentionally adds default parameters even if not originally present.
    # This is the desired behavior to ensure consistent URLs with normalized parameters.
    # The loop prevention check prevents infinite redirects.
    return if current_query == canonical_query

    # 並びを安定化（アルファベット順）して相対URLへ 302
    path = request.path
    location = canonical_query.empty? ? path : "#{path}?#{canonical_query}"

    redirect_to location,
                allow_other_host: false,
                status: :found # 本番で固定化したければ :moved_permanently（301）
  end
end

# 問題点
# - クエリパラメータがデフォルト値ならば、クエリを除去しても良いのでは？
# - 境界値（空文字列や nil）の扱いはどうするか？
#   → 現状は空文字列や nil はデフォルト値に正規化されるので、結果的にクエリから除去される
# - 多言語対応や多地域対応の観点から、URLに言語・地域情報を含めるべきか？
#   -> 見る人がで url で変化しないようにする。
#     -> これ大切だが、固定値は表示させないというのとコンフリクトが起きるので放棄することにした。
# - JWT のクッキーの値を URL に反映させるのはどうか？
# 優先順位 param > cookie > default
# 微妙に global と region ではパラメタの設定がちがう。
# 固定値ならばにurl に含めない。
# - URL に含めるべきパラメタはどれか？
#  - ri: language => これグローバルの環境では必須だが、リージョン環境では サブドメインに表記する。
