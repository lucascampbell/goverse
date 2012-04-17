require 'rho/rhocontroller'
require 'helpers/browser_helper'

### Currently only using live.rb RHOM ORM
class LiveController < Rho::RhoController
  include BrowserHelper

end
