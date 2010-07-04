## No routes needed anymore since Devise.add_module with the :route parameter will take care of it.

# ActionController::Routing::RouteSet::Mapper.class_eval do
# 
#   protected
#     # reuse the session routes and controller
#     alias :ldap_authenticatable :database_authenticatable
# end