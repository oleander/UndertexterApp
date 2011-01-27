#
#  Growl.rb
#  UndertexterApp
#
#  Created by Linus Oleander on 2011-01-27.
#  Copyright (c) 2011 Chalmers. All rights reserved.
#

class Growl
  
  def initialize(args)
    @title = "En fil har lags till"
    @message = "Ett okänt meddelande"
    args.keys.each { |name| instance_variable_set "@" + name.to_s, args[name] }
    
    GrowlApplicationBridge.setGrowlDelegate(self)
  end
  
  def self.send(args = {})
    growl = Growl.new(args); growl.send_to_user
  end
  
  def send_to_user
    GrowlApplicationBridge.notifyWithTitle(@title,description: @message, notificationName: "Test", iconData: nil, priority: 0, isSticky: false, clickContext: nil)
  end
end
