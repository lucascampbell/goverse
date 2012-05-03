# The model has already been created by the framework, and extends Rhom::RhomObject


### The LIVE model acts as a method for storing session data, see quote_controller.rb for example
class Live
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with Live.
  # enable :sync

  #add model specifc code here
  class << self
    attr_accessor :live
  end
end
