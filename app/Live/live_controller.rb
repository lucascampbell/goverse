require 'rho/rhocontroller'
require 'helpers/browser_helper'

### Currently only using live.rb RHOM ORM
class LiveController < Rho::RhoController
  include BrowserHelper 
  
  def get_image_link
    img = @params['image']
    @image_url = Live.image_link(img)
    render :action => :image_url, :layout => false
  end
end
