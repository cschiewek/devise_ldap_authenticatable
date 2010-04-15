ActionController::Routing::RouteSet::Mapper.class_eval do

  protected

    # reuse the session routes and controller
    alias :imapable :authenticatable

end