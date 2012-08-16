# Copyright (c) 2012 The First Church of Christ, Scientist.
# 
#    GNUv2.0:
# 
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
# 
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
# 
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
# 
#    Further inquiries can be directed towards app@goverse.org
# 
#    MIT:
# 
#    Permission is hereby granted, free of charge, to any person obtaining a
#    copy of this software and associated documentation files (the "Software"),
#    to deal in the Software without restriction, including without limitation
#    the rights to use, copy, modify, merge, publish, distribute, sublicense,
#    and/or sell copies of the Software, and to permit persons to whom the
#    Software is furnished to do so, subject to the following conditions:
# 
#    The above copyright notice and this permission notice shall be included
#    in all copies or substantial portions of the Software.
# 
#        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
#        OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#        MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#        IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#        CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#        TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
#        OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'rho/rhocontroller'
#require 'rho/rhoutils'
require 'helpers/browser_helper'
require 'helpers/application_helper'

class QuoteController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper
  
  def start
    @menu = { "Back" => "/app/Quote/show_by_id"}
    if Live.live.first_load == '0'
      @topic_name = 'test'
      @quote = Quote.find(:first)
      @quotes = []
      @topics = []
      render :action => :start
    else
      redirect :action => :show_by_id
    end
  end
  
  def callback_back
    redirect :action => :show_by_id
  end
  
  # This is the main method which shows the quote and photo screen
  def show_by_id
    NavBar.remove
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
      @image = "12"#(1 + rand(10) ).to_s
    end
    if @id.nil?      
      @id = QuoteTopic.find_first_active_quote_id
    end
    
    #store id and image for s3 reset call
    if Live.live.s3 == '0'
      Quote.quote_id = @id
      Quote.image_id = @image
    end
    
    # Find the specified quote
    @quote = Quote.find(:first,:conditions => {:id => @id})
    
    # Quote ids are allowed to seized to exist, this will assure a quote is select; optional: inform user     
    if @quote.nil?
      @quote = Quote.find(:first)#Quote.find(:first,:conditions => {:id => rand(1000)})3
    end
  
    # Select quotes in the same topic to fill the carousel; optional: randomize, prioritize and limit the order and amount of quotes
    @quotes = @quote.topic_quotes
    
    @topic_name = @quote.topic_name
    
    # Select available topics for the menu; optional: Filter sensitive topics
    @topics = Topic.find_active
   
    render :action => 'show_by_id'
  end 
  
  ### This is the Push-Notification callback method  
  def push_callback
      q = @params['quote']
      i = rand(Live.live.image_count.to_i) + 1
      id = q.to_s + "," + i.to_s
      quote = Quote.find(:first,:conditions => {:id => q})
      Alert.show_popup( {
        :message => quote.quote,
        :title => "Daily Quote",
        :buttons => ["OK"]
      })
      WebView.execute_js("switchQuote(#{id});")
      #WebView.navigate("/app/Quote/show_by_id?id=#{id}")
  end
  
  def device_token
    System.set_application_icon_badge(0)
    load_images
    token = System.get_property('device_id')
    puts "token is --- #{token}"
    if token.size > 60
      Live.register_push(token)
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
      #get search type or default to topic
      stype = @params["stype"] || "topic"
      @tag = @params["tag"].strip.downcase
      @quotes = nil
      
      case stype
      when "topic"
          quote_ids = QuoteTopic.find_ids_by_topic_name(@tag)
          @quotes = Quote.find_by_ids(quote_ids) if quote_ids
      when "tag"
          tag = Tag.find_by_name(@tag)
          if tag
            @quotes  = QuoteTag.get_quotes_by_tag(tag.id)
          else
            @quotes = nil
          end
      when "keyword"
          @quotes = Quote.find_by_string(@tag)
      else
          quote_ids = QuoteTopic.find_ids_by_topic_name(@tag)
          @quotes   = Quote.find_by_ids(quote_ids)
      end
     
      Quote.topic_header = @tag
      #save quotes so when list clicked search quotes are shown
      Quote.quotes = @quotes
      
      if @quotes and !@quotes.empty?
        render :action=>:search_result, :layout => false
      else
        render :action =>:search_empty, :layout => false
      end
    end
  end
   
  # Set favorite; setting and unsetting favorite should be decoupled from showing favorites
  def set_favorite
    parms = strip_braces(@params['id'])   
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
    #@topic = Topic.find_by_quote_id(id)
    @quote = Quote.find(:first,:conditions=>{:id=>id})
    render :action => :topic, :layout => false
  end
  
  def ajax_quote
    id      = strip_braces(@params['id'])
    image   = @params['image']
    @image_url = Live.image_link(image) if image
    @quote  = Quote.find(:first,:conditions=>{:id => id})
    @quote  = Quote.find(:first) if @quote.nil?
    @quotes = image ? @quote.topic_quotes : Quote.quotes.select{|q| q.id != id}
    
    #add topic quotes if topic only has one quote
    @quotes = @quote.topic_quotes if @quotes.empty?
    
    #get font size for citation based on iPad or phone
    @font_size = Live.live.device == 'ipad' ? "16px" : "9px"
    
    @topic_name = image ? @quote.topic_name : Quote.topic_header 
    render :action => :ajax_quote, :layout => false
  end
  
  ### Return list of quotes within a topic to populate browsing-list 
  def json_by_topic_id
    topic_id = strip_braces(@params['id'])  
        
    #revert to first topic if nothing passed    
    topic_id = '56' if topic_id.nil?
    
    @topic_name = Topic.find_by_id(topic_id).name
    @quotes = Quote.find_by_topic(topic_id)               
    @font_size = Live.live.device == 'ipad' ? "16px" : "9px"
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
    @width   = w > 480 ? 250 : 100
    @height  = w > 480 ? 350 : 150
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
    if q == 'noupdates'
      Alert.show_popup( {
          :message => 'Once your quote is reviewed and accepted it will be availble for others to see.', 
          :title => 'Quote submitted successfully', 
          :icon => '/public/images/icon.png',
          :buttons => ["OK"]
      })
    elsif q == 'Quote already exists'
      Alert.show_popup( {
           :message => 'This quote already exists. It is active or will be active soon.', 
           :title => 'Quote already exists', 
           :icon => '/public/images/icon.png',
           :buttons => ["OK"]
       })
    else
      Alert.show_popup( {
           :message => 'The quote service is temporarily down, please try again later.', 
           :title => 'Error submitting quote', 
           :icon => '/public/images/icon.png',
           :buttons => ["OK"]
       })
    end
  end
 
  def updatedb
    Quote.updatedb
  end
  
  def updatedb_callback
    params = @params['body']
    puts "body is -- #{params}"
    q   = params['q']
    id  = params['id']
    del = params['delete']
    up  = params['update']
    puts "up is #{up}"
    #process updates and deletes
    Quote.sync_changes(up,del) if up || del
    
    if q == 'noupdates'
      Alert.show_popup( {
          :message => 'There are no new updates at this time', 
          :title => '', 
          :icon => '/public/images/icon.png',
          :buttons => ["OK"]
      })
    elsif id
      Live.live.create_id = id
      Live.live.save
      Quote.insert_quotes(q)
      msg = q.size == 1 ? "You have 1 new quote." : "You have #{q.size} new quotes."
      Alert.show_popup( {
          :message => "#{msg} Update complete.", 
          :title => 'GoVerse updated successfully',
          :icon => '/public/images/icon.png',
          :buttons => ["OK"]
      })
    else
       Alert.show_popup( {
            :message => 'The quote service is temporarily down, please try again later.', 
            :title => 'Error updating',
            :icon => '/public/images/icon.png',
            :buttons => ["OK"]
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
       id = "#{Quote.quote_id},#{Quote.image_id}"
       puts "id is #{id}"
       WebView.navigate("/app/Quote/show_by_id?id=#{id}")
     else
       WebView.execute_js("toggle_updatedb();")
     end
  end
  
  def register_push_callback
    params = @params['body']
    puts "callback hit params #{params}"
    Live.live.registered = '1' if params['text'] == 'success'
  end
  
  def add_nav
    if System.get_property('platform') == "APPLE"
      NavBar.create :title => "GoVerse",
                    :left => {
                      :action => url_for(:controller=> 'Quote', :action => 'show_by_id'),
                      :label => "home"}
    end
  end
  
  def restart_app
    WebView.navigate('/app/Quote/show_by_id')
  end
end
