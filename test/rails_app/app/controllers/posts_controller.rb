class PostsController < ApplicationController
      
  before_filter :authenticate_user!, :except => [:index]
    
  def index
    # render :inline => "posts#index", :layout => "application"
    render :text => "posts#index"
  end
  
  def new
    # render :inline => "posts#new", :layout => "application"
    render :text => "posts#new"
  end

end
