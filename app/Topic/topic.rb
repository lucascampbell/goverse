# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Topic
  include Rhom::PropertyBag
  #belongs_to :quote
  # Uncomment the following line to enable sync with Topic.
  # enable :sync

  #add model specifc code here
  def self.find_active
    Topic.find(:all,:conditions=>{:active =>'true'},:order=>'name')
  end
end
