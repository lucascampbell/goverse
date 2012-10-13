require 'rho/rhoapplication'
class AppApplication < Rho::RhoApplication
  def initialize
    # Tab items are loaded left->right, @tabs[0] is leftmost tab in the tab-bar
    # Super must be called *after* settings @tabs!
    @tabs = nil
    #To remove default toolbar uncomment next line:
    @@toolbar = nil
    super
    # Uncomment to set sync notification callback to /app/Settings/sync_notify.
    # SyncEngine::set_objectnotify_url("/app/Settings/sync_notify")    
    System.set_push_notification("/app/Quote/push_callback", "")
    #SyncEngine.set_notification(-1, "/app/Settings/sync_notify", '')
    
    #db_version = '2.13' #Increase number to cause database to be reloaded from /fixtures/object_values.txt; MAKE SURE TO SAVE FAVORITES AND OTHER USER DATA
    #live = Live.find(:first, :conditions => {:controller => 'App', :action => 'Init', :value => db_version})
    live = Live.find('39000000000')
    if live.nil?
       Rho::RHO.load_all_sources()
       Rho::RhoUtils.load_offline_data(['object_values'], '../public')  #loads from /fixtures/object_values.txt  
       #Live.create(:controller => 'App', :action => 'Init', :value => db_version) #remember current db version in session model
       #set db models to do not backup initially
       Live.do_not_backup 
       Live.live = Live.find('39000000000') 
    else
      Live.live = live
    end
   
    #add new topic which will be 2.14
    #unless Live.live.db_version == '2.14'
    #       t = Topic.create(:id=>"57",:name=>"All New this Week",:visible=>"1")
    #       puts "topic is #{t}"
      #Live.live.db_version = '2.14'
      #Live.s3 = 0
      #Live.image_count = 12
      #Live.live.save
      #filename = File.join(Rho::RhoApplication::get_base_app_path(),dir)
    #end
    
    
    Live.live.delete_id = 0 unless Live.live.delete_id
    
    Live.live.update_id = 0 unless Live.live.update_id
    
    Live.live.create_id = 0 unless Live.live.create_id
    #hack for android to allow layout to load and cache files initially so swipeview functions properly
    
    if System.get_property('platform') == "ANDROID"
      Live.live.first_load = '0'
    else
      Live.live.first_load = '1'
    end
      
  end
  
end