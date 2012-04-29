# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class QuoteTag
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with QuoteTag.
  # enable :sync

  #add model specifc code here
  def self.get_quotes_by_tag(tag_id)
    ids = QuoteTag.find(:all,:conditions => {:tag_id => tag_id}).collect(&:quote_id)
    Quote.find(:all,:conditions => {{:name => "object", :op => "IN" } => ids })
  end
end
