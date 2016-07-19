# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
Mime::Type.register 'application/vnd.api+json', :json_api
ActionController::Renderers.add :json_api do |obj, _options|
  self.content_type ||= Mime[:json_api]
  obj
end
# Add JSON-API request data to params hash inside controllers
# http://blog.arkency.com/2016/03/creating-new-content-types-in-rails-4-dot-2/
middlewares = Cedar::Application.config.middleware
middlewares.swap(ActionDispatch::ParamsParser,
                 ActionDispatch::ParamsParser,
                 Mime::Type.lookup('application/vnd.api+json') => lambda do |body|
                   ActiveSupport::JSON.decode(body)
                 end)
