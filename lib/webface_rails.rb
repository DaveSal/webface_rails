require_relative "../app/helpers/webface_component_helper"
require_relative "../app/helpers/webface_form"

module WebfaceRails

  if defined?(Rails)
    class Engine < Rails::Engine
    end
  end

end
