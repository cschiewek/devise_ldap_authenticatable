class PostsController < ApplicationController
    
  before_filter :authenticate_user!, :except => [:index]
    
  def index
    render :text => "posts#index"
  end
  
  def show
    render :text => "posts#show"
  end

end
