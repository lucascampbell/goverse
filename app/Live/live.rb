# The model has already been created by the framework, and extends Rhom::RhomObject
require 'rho/rhoutils' 
### The LIVE model acts as a method for storing session data, see quote_controller.rb for example
class Live
  include Rhom::PropertyBag
  PATH  = Rho::RhoApplication::get_base_app_path()
  TOKEN = "&3!kZ1Ct:zh7GaM"
  URL   = "http://quotoservice.herokuapp.com/api/v1"
  #URL = "http://192.168.1.121:3000/api/v1"
   #testing http://quoteservicetest.herokuapp.com/api/v1
  # Uncomment the following line to enable sync with Live.
  # enable :sync

  #add model specifc code here
  class << self
    attr_accessor :live
  end
  
  def self.do_not_backup
    ['Live','Quote','QuoteTag','QuoteTopic','QuoteTag','Tag','Topic'].each do |mdl|
      require_model mdl
      db = Rho::RHO::get_src_db(mdl)
      db.set_do_not_bakup_attribute(1)
    end
  end
  
  def self.backup
    ['Live','Quote','QuoteTag','QuoteTopic','QuoteTag','Tag','Topic'].each do |mdl|
      require_model mdl
      db = Rho::RHO::get_src_db(mdl)
      db.set_do_not_bakup_attribute(0)
    end
  end
  
  def self.image_link(img)
    unless Live.live.device
      device = System.get_property('device_name')
      Live.live.device = device =~ /iPad/ ? 'ipad' : 'phone'
      Live.live.save
    end
    platform = System.get_property('platform')
    dir = Live.live.device
    path = "/public/#{dir}_photos/#{img}.jpg" if platform == "ANDROID"
    path = img.to_i > 12 ? "#{PATH}#{dir}/#{img}.jpg" : "/public/#{dir}_photos/#{img}.jpg" unless platform == "ANDROID"
    path
  end
  
  def self.register_push(token)
    p  = System.get_property('platform')
    t  = p == 'APPLE' ? normalize_token(token) : token
    
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
    load_and_zip if (Live.live.s3 == '0' and System.get_property('platform') != "ANDROID")
  end

  def load_and_zip
    #only do pull request if its been 3 minutes since first and still no s3 images found
    if Live.live.start_timer
      return if Time.now - Live.live.start_timer < 180
    end
    dir = Live.live.device
    filename = File.join(Rho::RhoApplication::get_base_app_path(),dir + '.zip')
    #filename2 = File.join(Rho::RhoApplication::get_base_app_path(),dir)
    File.delete(filename) if File.exists? filename
    #File.delete(filename2) if File.exists? filename2
    
    Rho::AsyncHttp.download_file(
       :url => "https://s3.amazonaws.com/tmc_quotes/#{dir}.zip",
       :headers => {},
       :callback => '/app/Quote/httpdownload_callback',
       :callback_param => "file=#{dir}",
       :filename => filename
       )
    #if first time or time > 180 set timer
    Live.live.start_timer = Time.now
  end
end
