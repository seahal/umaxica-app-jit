module ViteHelper
  def vite_javascript_tag(name, **options)
    asset_path = vite_asset_path("#{name}.js")
    return "" unless asset_path

    javascript_include_tag(asset_path, type: "module", **options)
  end

  def vite_stylesheet_tag(name, **options)
    asset_path = vite_asset_path("#{name}.css")
    return "" unless asset_path

    stylesheet_link_tag(asset_path, **options)
  end

  private

  def vite_asset_path(name)
    return nil unless vite_manifest

    # manifest.jsonのキーはsrc/ファイル名形式
    src_key = "src/#{name}"
    entry = vite_manifest[src_key]
    return nil unless entry

    # dist/からの相対パスを返す
    "/dist/#{entry['file']}"
  end

  def vite_manifest
    @vite_manifest ||= begin
      manifest_path = Rails.root.join("dist/.vite/manifest.json")
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
