require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'

class SettingsController < Rho::RhoController
  include BrowserHelper
  
  def index
    redirect :controller=>:quote, :action => :show_by_id
    #@msg = @params['msg']
    #render
  end

  
  def reset
    redirect :controller=>:quote, :action => :show_by_id
    #render :action => :reset
  end
  
  def do_reset
    
    #Rhom::Rhom.database_full_reset
    #SyncEngine.dosync
    #@msg = "Database has been reset."
    redirect :controller=>:quote, :action => :show_by_id
  end
 
end
