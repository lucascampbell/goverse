# The model has already been created by the framework, and extends Rhom::RhomObject
require 'rho/rhoutils' 
### The LIVE model acts as a method for storing session data, see quote_controller.rb for example
class Live
  include Rhom::PropertyBag
  PATH  = Rho::RhoApplication::get_base_app_path()
  TOKEN = "&3!kZ1Ct:zh7GaM"
  URL   = "http://quotoservice.herokuapp.com/api/v1"
  #URL = "http://192.168.1.121:3000/api/v1"
   #testing http://quoteservice.herokuapp.com/api/v1
  # Uncomment the following line to enable sync with Live.
  # enable :sync

  #add model specifc code here
  class << self
    attr_accessor :live
  end
  
  def self.image_link(img)
    dir = Live.live.device
    img.to_i > 21 ? "#{PATH}#{dir}/#{img}.jpg" : "/public/#{dir}_photos/#{img}.jpg"
  end
  
  def self.register_push(token)
    t = normalize_token(token)
    p = System.get_property('platform')
    Rho::AsyncHttp.post(
       :url => "#{URL}/register_device",
       :headers => {"AUTHORIZATION" => TOKEN},
       :body => "id=#{t}&platform=#{p}",
       :callback => '/app/Quote/register_push_callback'
     )
  end
  
  def self.normalize_token(token)
    token.insert(8," ").insert(17," ").insert(26," ").insert(35," ").insert(44," ").insert(53," ").insert(62," ") if token.size < 71
  end
  
  def s3_downloads
    load_and_zip if Live.live.s3 == '0'
  end

  def load_and_zip
    dir = Live.live.device
    filename = File.join(Rho::RhoApplication::get_base_app_path(),dir + '.zip')
    File.delete(filename) if File.exists? filename
    
    Rho::AsyncHttp.download_file(
       :url => "https://s3.amazonaws.com/tmc_quotes/phone.zip",
       :headers => {},
       :callback => '/app/Quote/httpdownload_callback',
       :callback_param => "file=#{dir}",
       :filename => filename
       )
  end
end
