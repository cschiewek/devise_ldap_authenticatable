class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  
  # before_filter :authenticate_user!
end
