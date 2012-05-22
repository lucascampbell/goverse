# The model has already been created by the framework, and extends Rhom::RhomObject
require 'rho/rhoutils' 
# You can add more methods here
class Quote
  include Rhom::PropertyBag
  TOKEN = "&3!kZ1Ct:zh7GaM"
  URL   = "http://quotoservice.herokuapp.com/api/v1"
  #URL = "http://192.168.1.121:3000/api/v1"
  #"http://localhost:3000/api/v1"
  #testing http://quoteservice.herokuapp.com/api/v1
  
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
    attr_accessor :quote_id
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
    })
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
    id = Live.live.id_last
    Rho::AsyncHttp.get(
       :url => "#{URL}/get_quotes?id=#{id}",
       :headers => {"AUTHORIZATION" => TOKEN},
       :callback => '/app/Quote/updatedb_callback'
     )
  end
  
  def self.insert_quotes(q)
    q.each do |quote|
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
    Topic.find_by_id(qt.topic_id).name
  end
  
end
