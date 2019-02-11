require_relative "../app/helpers/webface_component_helper"
require_relative "webface_rails/webface_form_component"

module WebfaceRails

  if defined?(Rails)
    class Engine < Rails::Engine
    end
  end

end
