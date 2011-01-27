require 'movie'
class SubController <  NSView
  
  attr_accessor :information_field, :loading, :details, :queue
  
  def initWithFrame(frame)
    super frame
    return self
  end
  
  def language_button(sender)
    @default_language = sender.selectedSegment
  end
  
  def awakeFromNib
    @language = {
      1 => :swedish,
      0 => :english 
    }
    
    @default_language = 1
    
    self.registerForDraggedTypes [NSURLPboardType, nil]
    @loading.image = NSImage.imageNamed("activityindicator.gif")
    @loading.animates = true
    @information_field.hidden = true
    @loading.hidden = false
  end
  
  def draggingEntered(sender)
    return NSDragOperationCopy
  end
  
  def done
    @information_field.hidden = false
    @loading.hidden = true
    @done_loading = true
  end
  
  def draggingExited(sender)
    self.needsDisplay = true
  end
  
  # Styr den lilla gröna ikonen som poppar upp när man håller musen över
  # Om objektet som hålls över är en fil så visas en grön ikon 
  def draggingUpdated(sender)
    return NSDragOperationCopy
  end

  def prepareForDragOperation(sender)
    return @done_loading
  end
  
  def draggingSourceOperationMaskForLocal(isLocal)
    return NSDragOperationCopy
  end
  
  def performDragOperation(sender)
    return @done_loading
  end

  def concludeDragOperation(sender)
    @sub = Sub.new(sender: sender)
    
    @information_field.hidden = true
    @details.hidden = true
    @loading.hidden = false
    
    @queue.async do
      
      data = Movie.find(@sub.working_data, @language[@default_language])      
      if data.subtitle
        @sub.success!(data.subtitle)
        @information_field.stringValue = data.movie.title
        @details.stringValue = data.subtitle.title
        @details.hidden = false
      else
        @information_field.stringValue = "Inget hittades"
      end
      
      @loading.hidden = true
      @information_field.hidden = false
    end
  end
  
  def draggingSourceOperationMaskForLocal(flag)
    return NSDragOperationCopy
  end
end