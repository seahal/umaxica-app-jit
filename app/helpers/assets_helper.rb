module AssetsHelper
  # Infer tenant key from request host.
  # Returns "org" or "com"; default to "com" if not clearly org.
  def tenant_key
    host = request.host.to_s
    return "org" if host.include?("org")
    "com"
  end

  # Link tag helper for tenant-scoped stylesheets.
  # Expects stylesheets to live under app/assets/stylesheets/<section>/<tenant>/main.css
  # Example: tenant_stylesheet("apex") => stylesheet_link_tag("apex/com/main")
  def tenant_stylesheet(section, name = "main")
    logical_path = File.join(section.to_s, tenant_key, name.to_s)
    stylesheet_link_tag logical_path
  end

  # Image tag helper for tenant-scoped images with optional shared fallback name.
  # Places images under app/assets/<tenant>/... or app/assets/shared/...
  def tenant_image(name, **options)
    image_tag(File.join(tenant_key, name.to_s), **options)
  end
end
