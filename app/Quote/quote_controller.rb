require 'rho/rhocontroller'
#require 'rho/rhoutils'
require 'helpers/browser_helper'
require 'helpers/application_helper'

class QuoteController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper
  
  # This is the main method which shows the quote and photo screen
  def show_by_id
    #System.set_application_icon_badge(0) # After a push-notification set a badge number, this will reset it; PUSH Not. and badge-resets should also be called by AJAX to avoid page reloads                 
    parms = strip_braces(@params['id']) 
      
    # This can use some cleaner error handling :-)   
    if parms.nil?
      parms =  ','
    end
    
    # swipe view _resize passes quote_id,image_id to this function so params are split
    parms = parms.split(',')
    @id = parms[0]
    @image = parms[1]
    
    if @image.nil?      
      @image = (rand(Live.live.image_count.to_i) + 1).to_s
    end
    if @id.nil?      
      @id = '1'#(rand(1000) + 1).to_s
    end    
    
    # Find the specified quote
    @quote = Quote.find(:first,:conditions => {:id => @id})
    
    # Quote ids are allowed to seized to exist, this will assure a quote is select; optional: inform user     
    if @quote.nil?
      @quote = Quote.find(:first)#Quote.find(:first,:conditions => {:id => rand(1000)})
    end
  
    # Select quotes in the same topic to fill the carousel; optional: randomize, prioritize and limit the order and amount of quotes
    @quotes = @quote.topic_quotes
    
    @topic_name = @quote.topic_name
    
    # Select available topics for the menu; optional: Filter sensitive topics
    @topics = Topic.find_active  
    render :action => :show_by_id, :layout => false
  end 
  
  ### This is the Push-Notification callback method  
  def push_callback
    q = @params['quote']
    i = rand(Live.live.image_count.to_i) + 1
    id = q.to_s + "," + i.to_s
    WebView.navigate("/app/Quote/show_by_id?id=#{id}")
  end
  
  def device_token
    device = System.get_property('device_name')
    Live.live.device = device =~ /iPad/ ? 'ipad' : 'phone'
    Live.live.save
    unless Live.live.registered == '1'
      token = System.get_property('device_id')
      puts "token is --- #{token}"
      if token.size > 60
        Live.register_push(token)
      end
    end
  end
  
  def load_images
    Live.live.s3_downloads if Live.live.s3 == '0'
  end
  
  ### Return search results to on-screen list 
  def search_result
    #if nothing passed return active topics
    if @params["tag"] == ""
      @topics = Topic.find_active
      render :action => :ajax_topics, :layout => false
    else
      #search quote tags first
      tag_name = @params["tag"].strip.downcase
      tag = Tag.find_by_name(tag_name)     
      ids = nil
      @quotes = QuoteTag.get_quotes_by_tag(tag.id) if tag
      
      #get ids from first search and pass to second query so as not to get duplicates  
      ids = @quotes.collect(&:id) unless @quotes.nil?
      
      q2 = Quote.find_by_exclusive(@params["tag"],ids) if ids
      
      @quotes = Quote.find_by_string(@params["tag"]) unless ids
      @quotes += q2 if (q2 and !q2.empty?)
      
      if @quotes
        render :action=>:search_result, :layout => false
      else
        render :action =>:search_empty, :layout => false
      end
    end
  end
   
  # Set favorite; setting and unsetting favorite should be decoupled from showing favorites
  def set_favorite
    parms = strip_braces(@params['id'])
    puts "params are --- #{parms}"    
    if parms.nil?
      parms = '0,1'
    end
    
    parms = parms.split(',')
    id = parms[0]
    image = parms[1]    
        
    if image.nil?      
      image = '1'
    end  
    
    quote = Quote.find(:first,:conditions=>{:id => id})
    quote.update_attributes(:favorite => 'y',:favorite_image => image)
    #redirect :action => :ajax_favorites
  end
  
  def unset_favorite 
    id = strip_braces(@params['id'])    
    quote = Quote.find(:first,:conditions=>{:id => id})
    quote.update_attributes(:favorite => 'n')    
    #redirect :action => :ajax_favorites
  end
  
  def get_topic
    id = strip_braces(@params['id'])
    @topic = Topic.find_by_quote_id(id)
    puts "topic found is -- #{@topic.name}"
    render :action => :topic, :layout => false
  end
  
  def ajax_quote
    id      = strip_braces(@params['id'])
    image   = @params['image']
    @image_url = Live.image_link(image) if image
    @quote  = Quote.find(:first,:conditions=>{:id => id})
    @quote  = Quote.find(:first)  if @quote.nil?
    @quotes = @quote.topic_quotes
    @topic_name = @quote.topic_name
    puts "quotes found are -- #{@quotes}"
    render :action => :ajax_quote, :layout => false
  end
  
  ### Return list of quotes within a topic to populate browsing-list 
  def json_by_topic_id
    topic_id = strip_braces(@params['id'])  
        
    #revert to first topic if nothing passed    
    topic_id = '56' if topic_id.nil?
    
    @topic_name = Topic.find_by_id(topic_id).name
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
    @quotes = Quote.find_all_favorites
    render :action => :ajax_favorites, :layout => false
  end
  
  def ajax_images
    w = @params['width'].to_i
    @width   = w > 320 ? 200 : 100
    @height  = w > 320 ? 300 : 150
    @padding = (w % @width) / 2
    @breaks  = w/@width.floor
    render :layout => false
  end
  
  def quote_submit
    quote = @params['quote']
    book = @params['book']
    citation = @params['citation']
    Quote.quote_submit(quote,book,citation)
  end
  
  def submit_quote_callback
    params = @params['body']
    q  = params['q']
    t  = params['t']
    id = params['id']
    # unless id.nil?
    #       puts "Live.live.id_last = #{Live.live.id_last}"
    #       Live.live.id_last = id
    #       Live.live.save
    #     end
    if q == 'noupdates' && id
      Alert.show_popup( {
          :message => 'Once your quote is reviewed and accepted it will be availble for others to see.', 
          :title => 'Quote submitted successfully', 
          :icon => '/public/images/icon.png',
          :buttons => ["Ok"]
      })
    elsif q 
      Quote.insert_quotes(q) unless q == 'noupdates'
      Alert.show_popup( {
           :message => 'This quote already exists. It is active or will be active soon.', 
           :title => 'Quote already exists', 
           :icon => '/public/images/icon.png',
           :buttons => ["Ok"]
       })
    else
      Alert.show_popup( {
           :message => 'The quote service is temporarily down, please try again later.', 
           :title => 'Error submitting quote', 
           :icon => '/public/images/icon.png',
           :buttons => ["Ok"]
       })
    end
  end
 
  def updatedb
    Quote.updatedb
  end
  
  def updatedb_callback
    params = @params['body']
    puts "body is -- #{params}"
    q  = params['q']
    id = params['id']
    if q == 'noupdates'
      Alert.show_popup( {
          :message => 'There were not any new quotes available. Now checking images...', 
          :title => 'Update complete', 
          :icon => '/public/images/icon.png',
          :buttons => ["Ok"]
      })
    elsif id
      Live.live.id_last = id
      Live.live.save
      Quote.insert_quotes(q)
      Alert.show_popup( {
          :message => "You have #{q.size} new quotes", 
          :title => 'Quoto updated successfully', 
          :icon => '/public/images/icon.png',
          :buttons => ["Ok"]
      })
    else
       Alert.show_popup( {
            :message => 'The quote service is temporarily down, please try again later.', 
            :title => 'Error updating',
            :icon => '/public/images/icon.png',
            :buttons => ["Ok"]
        })
    end
    if Live.live.s3 == '0'
      Live.live.s3_downloads
    else
      WebView.execute_js("toggle_updatedb();")
    end
  end
  
  def httpdownload_callback
     name      = @params['file']
     filename  = File.join(Rho::RhoApplication::get_base_app_path(),name + '.zip')
     filename2  = File.join(Rho::RhoApplication::get_base_app_path(),name)
     filename3  = File.join(Rho::RhoApplication::get_base_app_path(),name,'21.jpg')
     message   = 'nope'
     puts "file exists #{File.exist?(filename)}"
     if File.exist?(filename)
       System.unzip_file(filename)
       File.delete(filename)
       message = "success" if File.directory?(filename2) && File.exists?(filename3)
     end

     if message == 'success'
       Live.live.s3 = '1' 
       Live.live.image_count = 57
       Live.live.save
       WebView.navigate('/app/Quote/show_by_id')
     else
       WebView.execute_js("toggle_updatedb();")
     end
  end
  
  def register_push_callback
    params = @params['body']
    puts "callback hit params #{params}"
    Live.live.registered = '1' if params['text'] == 'success'
  end
end
