#
#  MainController.rb
#  UndertexterApp
#
#  Created by Linus Oleander on 2011-01-23.
#  Copyright (c) 2011 Chalmers. All rights reserved.
#

class MainController
  def draggingEntered(sender)
    NSLog("DRAG!")
  end
  
  def concludeDragOperation(sender)
    NSLog("Nu då?")
  end
  
  def draggingExited(sender)
    NSLog("sfsdfsdf")
  end
  
  def getPath(sender)
    NSLog("OKOKOKO")
  end
end
