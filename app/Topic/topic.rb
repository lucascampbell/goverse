# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Topic
  include Rhom::PropertyBag
  #belongs_to :quote
  # Uncomment the following line to enable sync with Topic.
  # enable :sync

  #add model specifc code here
  def self.find_active
    Topic.find(:all,:conditions=>{:visible =>'1'},:order=>'name')
  end
  
  def self.find_random_active
    r = rand(25)
    Topic.find_active[r]
  end
  
  def self.find_by_id(id)
    Topic.find(:first,:conditions=>{:id=>id})
  end
  
  def self.find_by_name(t_name)
    Topic.find(:first,:conditions => {:name => t_name}) 
  end
  
  def self.find_by_quote_id(id)
    q = QuoteTopic.find(:first,:conditions=>{:quote_id=> id})
    t = Topic.find(:first,:conditions=>{:id=>q.topic_id,:visible=>'1'})
    t = Topic.find(:first,:conditions=>{:id=>q.topic_id}) unless t
    t
  end
end
