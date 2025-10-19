module DefaultUrlOptions
  extend ActiveSupport::Concern

  def default_url_options
    super.merge(ri: "jp", tz: "jst", lx: "ja")
  end
end
