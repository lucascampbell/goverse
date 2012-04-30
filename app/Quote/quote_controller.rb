require 'rho/rhocontroller'
#require 'rho/rhoutils'
require 'helpers/browser_helper'
require 'helpers/application_helper'

class QuoteController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper
 
  
  ### Used to be the splash screen, calling it init would be more appropriate
  def splash    
    #System.set_push_notification("/app/Quote/pushy", "") #Has to be set once
    db_version = '2.12' #Increase number to cause database to be reloaded from /fixtures/object_values.txt; MAKE SURE TO SAVE FAVORITES AND OTHER USER DATA
    #live = Live.find(:first, :conditions => {:controller => 'App', :action => 'Init', :value => db_version})
    #live = Live.find(:first)
    #if live.nil?
      #Rhom::Rhom.database_full_reset
      Rho::RHO.load_all_sources()     
    
      Rho::RhoUtils.load_offline_data(['object_values'], '../public')  #loads from /fixtures/object_values.txt       
      #Live.create(:controller => 'App', :action => 'Init', :value => db_version) #remember current db version in session model
      
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
           
    redirect :action => :show_by_id             
  end
  
  ### This is the main method which shows the quote and photo screen
  def show_by_id    
    #System.set_application_icon_badge(0) # After a push-notification set a badge number, this will reset it; PUSH Not. and badge-resets should also be called by AJAX to avoid page reloads                 
    parms = strip_braces(@params['id']) 
      
    ### This can use some cleaner error handling :-)   
    if parms.nil?
      parms =  ','
    end
    
    parms = parms.split(',')
    @id = parms[0]
    @image = parms[1]
    
    if @image.nil?      
      @image = '1'#(rand(55) + 1).to_s
    end
    if @id.nil?      
      @id = '1'#(rand(1000) + 1).to_s
    end    
    
    ### Find the specified quote
    @quote = Quote.find(:first,:conditions => {:object => @id})
      
    ### Quote ids are allowed to seized to exist, this will assure a quote is select; optional: inform user     
    while @quote.nil?
      @quote = Quote.find(:first)#Quote.find(:first,:conditions => {:id => rand(1000)})
    end
    
    ### Select quotes in the same topic to fill the carousel; optional: randomize, prioritize and limit the order and amount of quotes
    @quotes = Quote.find(:all, :conditions => {:topic_id => @quote.topic_id})
      
    
    ### Select available topics for the menu; optional: Filter sensitive topics
    @topics = Topic.find_active  
    
    ### Done
    render :action => :show_by_id, :layout => false
    
  end  
  
  ### This is the Push-Notification callback method  
  def pushy
    WebView.navigate url_for('/app/Quote/{'+@params['quoteid']+','+@params['image']+'}/show_by_id')
    #Alert.show_popup('push_notify: ' + @params.inspect)
  end
  
  
  ### Return search results to on-screen list 
  def search_result
    #if nothing passed return active topics
    if @params["tag"] == ""
      @topics = Topic.find_active 
      render :action => :ajax_topics, :layout => false
    else
      #search quote tags first
      tag_name = @params["tag"].downcase
      tag = Tag.find(:first,:conditions => {:name => tag_name})      
      ids = nil
          
      @quotes = QuoteTag.get_quotes_by_tag(tag.object) if tag
      
      #get ids from first search and pass to second query so as not to get duplicates  
      ids = @quotes.collect(&:object) unless @quotes.nil?
     
      q2 = Quote.find_by_exclusive(@params["tag"],ids) if ids
      @quotes = Quote.find_by_string(@params["tag"]) unless ids
      @quotes << q2 if (q2 and !q2.empty?)
  
      if @quotes
        render :action=>:search_result, :layout => false
      else
        render :action =>:search_empty, :layout => false
      end
    end
  end
   
  ### Set favorite; setting and unsetting favorite should be decoupled from showing favorites
  def set_favorite
    parms = strip_braces(@params['id'])       
    if parms.nil?
      parms = '0,1'
    end
    parms = parms.split(',')
    id = parms[0]
    image = parms[1]        
    if image.nil?      
      image = '7'
    end  
    quote = Quote.find(:first, :conditions => {:id => id})
    quote.update_attributes(:favorite => 'y', :favorite_image => image)    
    redirect :action => :ajax_favorites
  end
  
  def unset_favorite 
    id = strip_braces(@params['id'])    
    quote = Quote.find(:first, :conditions => {:id => id})
    quote.update_attributes(:favorite => 'n')    
    redirect :action => :ajax_favorites
  end    

  ### This is the only page not loaded by ajax; also the view needs better performance
  def photos
    @id = strip_braces(@params['id'])
    render :layout => false
  end
  
  #
  # The rest are all methods returning json to the show_by_id webview
  # 
  
  ### Return a quote and its associated topic-buddies by json after it is discovered by browsing or searching
  ### Here is opportunity to DRY by consolidating some of the repeated code from show_by_id into an helper method
  def json
    parms = strip_braces(@params['id']) 
         
    if parms.nil?
      parms = '0,1'
    end
    parms = parms.split(',')
    id = parms[0]
    @image = parms[1]
    if @image.nil?      
      @image = "1"#(rand(55) + 1).to_s
    end
    
    @quote = Quote.find(:first,:conditions => {:object => id})   
    puts "quote is #{@quote}"  
    if @quote.nil?
      @quote = Quote.find(:first)#Quote.find(:first,:conditions => {:id => rand(1000)})
    end
    
    @quotes = Quote.find_by_topic(@quote.topic_id)               
    
    ### Switch to using built-in render json function
    render :action => :json, :layout => false
    
  end   
  
  ### Return list of quotes within a topic to populate browsing-list 
  def json_by_topic_id
    topic_id = strip_braces(@params['id'])  
        
    #revert to first topic if nothing passed    
    topic_id = '1' if topic_id.nil?
    
    @quotes = Quote.find_by_topic(topic_id)               
    
    render :action => :json_by_topic_id, :layout => false
  end  
  
  ### Provide list of available topics for on-screen browsing menu
  def ajax_topics
    @topics = Topic.find_active
    render :action => :ajax_topics, :layout => false
  end
  
  ### Populate favorites-list when show-favorites is called
  def ajax_favorites
    @quotes = Quote.find(:all, :conditions => {:favorite=>'y'})  
    render :action => :ajax_favorites, :layout => false
  end
 
end
