# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class QuoteTopic
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with QuoteTopic.
  # enable :sync

  #add model specifc code here
  def self.get_quotes_by_topic(topic_id)
    ids = QuoteTopic.find(:all,:conditions => {:topic_id => topic_id}).collect(&:quote_id) 
    Quote.find(:all,:conditions => {{:name => "id", :op => "IN" } => ids }) if ids
  end
  
  def self.find_ids_by_topic_name(name)
    t = Topic.find_by_name(name)
    QuoteTopic.find(:all,:conditions=>{:topic_id => t.id}).collect(&:quote_id) if t
  end
  
  def self.find_first_active_quote_id
    t  = Topic.find_random_active
    qt = QuoteTopic.find(:first,:conditions=>{:topic_id=>t.id})
    qt.quote_id
  end
  
end
