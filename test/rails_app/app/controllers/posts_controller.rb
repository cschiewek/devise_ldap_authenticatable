class PostsController < ApplicationController
    
  before_filter :authenticate_user!, :except => [:index]
    
  def index
    render :text => "posts#index"
  end
  
  def new
    render :text => "posts#new"
  end

end
