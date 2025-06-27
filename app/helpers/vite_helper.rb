module ViteHelper
  def vite_javascript_tag(name, **options)
    asset_path = vite_asset_path("#{name}.js")
    return '' unless asset_path
    
    javascript_include_tag(asset_path, type: 'module', **options)
  end

  def vite_stylesheet_tag(name, **options)
    asset_path = vite_asset_path("#{name}.css")
    return '' unless asset_path
    
    stylesheet_link_tag(asset_path, **options)
  end

  private

  def vite_asset_path(name)
    return nil unless vite_manifest
    
    entry = vite_manifest[name]
    return nil unless entry
    
    # Rails asset pipeline経由で配信
    entry['file']
  end

  def vite_manifest
    @vite_manifest ||= begin
      manifest_path = Rails.root.join('app/assets/builds/.vite/manifest.json')
      if File.exist?(manifest_path)
        JSON.parse(File.read(manifest_path))
      else
        {}
      end
    rescue JSON::ParserError
      {}
    end
  end
end