# The model has already been created by the framework, and extends Rhom::RhomObject
require 'rho/rhoutils' 
# You can add more methods here
class Quote
  include Rhom::PropertyBag
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
  
  def self.find_by_exclusive(search_word,ids=[])
    Quote.find(:all,:conditions=>{
              {
                :name => "quote",
                :op    => "LIKE"
              } => "%#{search_word}%",
              {
                :name => "object",
                :op   =>  "NOT IN"
              } => ids
    })
  end
  
  def self.find_by_string(search_word)
    Quote.find(:all,:conditions=>{
              {
                :name => "quote",
                :op    => "LIKE"
              } => "%#{search_word}%"
    })
  end
  
end
