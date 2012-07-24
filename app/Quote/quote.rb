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

# The model has already been created by the framework, and extends Rhom::RhomObject
require 'rho/rhoutils' 
# You can add more methods here
class Quote
  include Rhom::PropertyBag
  TOKEN = "&3!kZ1Ct:zh7GaM"
  #URL   = "http://quotoservicetest.herokuapp.com/api/v1"
  #"http://localhost:3000/api/v1"
  URL =  "http://quotoservice.herokuapp.com/api/v1"
  
  #has_many :topics
   # Uncomment the following line to enable sync with Product.
   # enable :sync
  #property :id, :string
  #property :bible, :string
  #property :author, :string
  #property :book, :string
  #property :citation, :string
  #property :book_key, :string
  #property :quote, :string
  #property :top_translation, :string  
  #property :topic, :string
  #property :tags, :string
  #property :tags2, :string
  #property :tags3, :string
  #property :favorite, :string
  #property :favorite_image, :string

  # Uncomment the following line to enable sync with Quote.
  # enable :sync

  #add model specifc code here
  class << self
    attr_accessor :quote_id, :image_id, :topic_header, :quotes
  end
  
  def self.find_by_ids(ids)
    Quote.find(:all,:order=>'rating',:conditions=>{
              {
                :name => "id",
                :op    => "IN"
              } => ids,
    })
  end
  
  def self.find_by_exclusive(search_word,ids=[])
    Quote.find(:all,:order=>'rating',:conditions=>{
              {
                :name => "quote",
                :op    => "LIKE"
              } => "%#{search_word}%",
              {
                :name => "id",
                :op   =>  "NOT IN"
              } => ids
          },
          :op => 'AND'
    )
  end
  
  def self.find_by_string(search_word)
    Quote.find(:all,:order=>'rating',:conditions=>{
              {
                :name => "quote",
                :op    => "LIKE"
              } => "%#{search_word}%"
    })
  end
  
  def self.find_by_topic(topic_id)
    q_ids = QuoteTopic.find(:all,:conditions=>{:topic_id => topic_id}).collect(&:quote_id)
    Quote.find(:all,:order=>'rating',:conditions => {
      {
        :name => 'id',
        :op   => 'IN'
      } => q_ids
    })
  end
  
  def self.find_by_exclusive_topic(topic_id,ids)
    q_ids = QuoteTopic.find(:all,:conditions=>{:topic_id => topic_id}).collect(&:quote_id)
    q_ids.delete_if{|q| ids.include? q}
    Quote.find(:all,:order=>'rating',:conditions => {
      {
        :name => 'id',
        :op   => 'IN'
      } => q_ids,
    })
  end
  
  def self.find_all_favorites
    Quote.find(:all,:conditions => {:favorite => 'y'})
  end
  
  def self.quote_submit(quote,book,citation)
    id_last = Live.live.id_last
    Rho::AsyncHttp.post(
      :url =>  "#{URL}/set_quote",
      :headers => {"AUTHORIZATION" => TOKEN},
      :body => "quote=#{quote}&book=#{book}&citation=#{citation}&id_last=#{id_last}",
      :callback => '/app/Quote/submit_quote_callback'
    )
  end
  
  def self.updatedb
    idd = Live.live.create_id
    d  = Live.live.delete_id
    up = Live.live.update_id
    Rho::AsyncHttp.get(
       :url => "#{URL}/get_quotes?id=#{idd}&delete_id=#{d}&update_id=#{up}",
       :headers => {"AUTHORIZATION" => TOKEN},
       :callback => '/app/Quote/updatedb_callback'
     )
  end
  
  def self.insert_quotes(q)
    q.each do |quote|
      puts "quote is #{q}"
      q = Quote.find(:first,:conditions=>{:id => quote['id']})
      unless q
        Quote.create({
          :quote        => quote['quote'],
          :id           => quote['id'],
          :author       => quote['author'],
          :abbreviation => quote['abbreviation'],
          :bible        => quote['bible'],
          :citation     => quote['citation'],
          :book         => quote["book"],
          :rating       => quote["rating"],
          :translation  => quote["translation"]
        })
        quote["tag_ids"].each do |t_id|
          #add remote logging here to see if tag ids are not found
          # make sure tag exists and we haven't already created row for inner join table
          qt = QuoteTag.find(:first,:conditions=>{:quote_id => quote['id'],:tag_id=>t_id})
          t = Tag.find_by_id(t_id)
          q = QuoteTag.create({:quote_id=>quote['id'],:tag_id=>t_id}) if t and !qt
        end
        quote["topic_ids"].each do |tp_id|
          #add remote logging here to see if tag ids are not found
          # make sure tag exists and we haven't already created row for inner join table
          qt = QuoteTopic.find(:first,:conditions=>{:quote_id => quote['id'],:topic_id=>tp_id})
          t = Topic.find_by_id(tp_id)
          QuoteTopic.create({:quote_id=>quote['id'],:topic_id=>tp_id}) if t and !qt
        end
      end
    end
  end
  
  def self.sync_changes(up,del)
    update_quotes(up)
    delete_quotes(del)
  end
  
  def self.update_quotes(up)
    return unless up
    up.each do |quote|
       puts "quote id is #{quote['quote_id']}"
       if quote['last_id']
         Live.live.update_id = quote['last_id']
         Live.live.save
       else
         @q = Quote.find(:first,:conditions=>{:id => quote['quote_id']})
         puts "quote initially is #{@q}"
         if @q
           puts "found quote"
           quote.each do |key,value|
             case key
             when "tags"
               @q.add_tags(value)
             when "topics"
               @q.add_topics(value)
             else
               @q.send("#{key}=",value) #if q.respond_to?(key.to_sym)
             end
           end
           puts "quote is now #{@q}"
           res = @q.save
           q2 = Quote.find(:first,:conditions=>{:id => quote['quote_id']})
           puts "quote is now #{q2}"
         else
           puts "quote id wrong #{quote['quote_id']} couldnt process"
         end
       end
     end
  end
  
  def self.delete_quotes(del)
    puts "del is #{del}"
    return unless del and del['ids']
    del['ids'].split(',').each do |id|
      q = Quote.find(:first,:conditions=>{:id => id.to_i})
      puts "about to destroy quote #{q}"
      q.destroy if q
    end
    Live.live.delete_id = del['last_id']
    Live.live.save
  end
  
  def add_tags(tags)
    QuoteTag.clear_tags(self.id)
    tags.split(',').each do |t|
      tag = Tag.find(:first,:conditions=>{:id=> t})
      puts "tag found is #{tag}"
      QuoteTag.create({:quote_id=>self.id,:tag_id=>tag.id}) if tag
    end
  end
  
  def add_topics(topics)
    QuoteTopic.clear_topics(self.id)
    topics.split(',').each do |t|
      topic = Topic.find(:first,:conditions=>{:id=> t})
      puts "topic found is #{topic}"
      QuoteTopic.create({:quote_id=>self.id,:topic_id=>topic.id}) if topic
    end
  end
  
  def topic_quotes
    t_ids = QuoteTopic.find(:all,:conditions=>{:quote_id=>self.id}).collect(&:topic_id).uniq
    q_ids = QuoteTopic.find(:all,:conditions=>{
      {
        :name => 'topic_id',
        :op   => 'IN'
      } => t_ids
    }).collect(&:quote_id).uniq
    Quote.find(:all,:order=>'rating',:conditions=>{
              {
                :name => 'id',
                :op   => 'IN'
              } => q_ids,
              {
                :name => "id",
                :op    => "<>"
              } => self.id
            },
            :op => 'AND'
    )
  end
  
  def topic_name
    qt = QuoteTopic.find(:first,:conditions=>{:quote_id => self.id})
    Topic.find_by_id(qt.topic_id).name if qt
  end
  
end
