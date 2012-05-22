# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class QuoteTopic
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with QuoteTopic.
  # enable :sync

  #add model specifc code here
  def self.get_quotes_by_topic(topic_id)
    ids = QuoteTopic.find(:all,:conditions => {:topic_id => topic_id}).collect(&:quote_id)
    Quote.find(:all,:conditions => {{:name => "id", :op => "IN" } => ids })
  end
  
end
