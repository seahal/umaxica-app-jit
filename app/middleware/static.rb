class Static
  def initialize(app, root:, tenants:, default_tenant:)
    @app = app
    @root = root.to_s
    @tenants = tenants
    @default_tenant = default_tenant
  end
end