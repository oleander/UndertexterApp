#
#  AppController.rb
#  UndertexterApp
#
#  Created by Linus Oleander on 2011-01-23.
#  Copyright (c) 2011 Chalmers. All rights reserved.
#

class AppController
  attr_accessor :window
  
  def awakeFromNib
    # Fönstret ska alltid vara överst
    self.window.level = NSFloatingWindowLevel
  end
end
