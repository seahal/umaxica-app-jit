
module DefaultUrlOptions
  extend ActiveSupport::Concern

  def default_url_options
    { ri: 'jp', tz: 'jst', lx: 'ja'  }
  end
end