class AppController
  attr_accessor :window, :sub_controller
  
  def awakeFromNib
    # Fönstret ska alltid vara överst
    self.window.level = NSFloatingWindowLevel
  end
  
  def applicationWillFinishLaunching(notification)
    @sub_controller.queue = Dispatch::Queue.new('net.undertexter.com')
    
    @sub_controller.queue.async do
      require 'rubygems'
      require 'undertexter'
      require 'movie_searcher'
      require 'dam_lev'
      require 'mimer'
      @sub_controller.done
    end
  end
  
  def applicationDidFinishLaunching(notification)
    @window.orderFront(self) unless @application
  end
  
  def application(sender, openFile:path)
    @application = true
    Growl.send(title: "Påbörjad", message: "Hämtningen är nu påbörjad")
    @sub_controller.queue.async do
      @window.close
    
      @sub = Sub.new(path: path)
      data = Movie.find(@sub.working_data, :swedish)      
    
      if data.subtitle
        @sub.success!(data.subtitle)
        Growl.send(title: "Allt gick bra", message: "Undertexten till filmen #{data.movie.title} är nu hämtad")
      end 
    
      NSApp.terminate(self)
    end
    return true
  end
end
