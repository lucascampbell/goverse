# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Tag
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with Tags.
  # enable :sync

  #add model specifc code here
  
  def self.find_by_id(id)
    Tag.find(:first,:conditions=>{:id=>id})
  end
  
  def self.find_by_name(t_name)
    Tag.find(:first,:conditions => {:name => t_name}) 
  end
end
