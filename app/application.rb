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
    System.set_push_notification("/app/Quote/pushy", "")
    SyncEngine.set_notification(-1, "/app/Settings/sync_notify", '')
    
    db_version = '2.12' #Increase number to cause database to be reloaded from /fixtures/object_values.txt; MAKE SURE TO SAVE FAVORITES AND OTHER USER DATA
    #live = Live.find(:first, :conditions => {:controller => 'App', :action => 'Init', :value => db_version})
    #if live.nil?
       #Rhom::Rhom.database_full_reset
       Rho::RHO.load_all_sources()     

       Rho::RhoUtils.load_offline_data(['object_values'], '../public')  #loads from /fixtures/object_values.txt       
       Live.create(:controller => 'App', :action => 'Init', :value => db_version) #remember current db version in session model
       Live.live = Live.find('39000000000')
       ### Add some default favorites
       #quote = Quote.find(:first, :conditions => {:id => '1'}) #was 10
       #quote = Quote.find(:first)
       #quote.update_attributes(:favorite => 'y',:favorite_image => '44')

       # quote = Quote.find(:first, :conditions => {:id => '341'})
       #       quote.update_attributes(:favorite => 'y',:favorite_image => '41')
       #             
       #       quote = Quote.find(:first, :conditions => {:id => '418'})
       #       quote.update_attributes(:favorite => 'y',:favorite_image => '4')
       #             
       #       quote = Quote.find(:first, :conditions => {:id => '22'})
       #       quote.update_attributes(:favorite => 'y',:favorite_image => '32')         
    #end
  end
end