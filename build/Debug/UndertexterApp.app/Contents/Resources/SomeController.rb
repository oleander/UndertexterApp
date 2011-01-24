class SomeController <  NSView
  
  attr_accessor :information_field, :loading
  
  def initWithFrame(frame)
    super(frame)
    return self
  end
  
  def awakeFromNib
    self.registerForDraggedTypes [NSURLPboardType, nil]
    @loading.image = NSImage.imageNamed("activityindicator.gif")
    @loading.animates = true
    @loading.hidden = true
    @queue = Dispatch::Queue.new('net.undertexter.com')
  end
  
  def draggingEntered(sender)
    return  NSDragOperationCopy
  end

  def draggingExited(sender)
    self.needsDisplay = true
  end
  
  # Styr den lilla gröna ikonen som poppar upp när man håller musen över
  # Om objektet som hålls över är en fil så visas en grön ikon 
  def draggingUpdated(sender)
    return is_file?(sender) ? NSDragOperationCopy : NSDragOperationNone
  end

  def prepareForDragOperation(sender)
    return self.is_file?(sender)
  end
  
  def draggingSourceOperationMaskForLocal(isLocal)
    return NSDragOperationCopy
  end
  
  def performDragOperation(sender)
    return self.is_file?(sender)
  end

  def concludeDragOperation(sender)
    @information_field.hidden = true
    @loading.hidden = false
    
    @queue.async do
      sleep 1
      @loading.hidden = true
      @information_field.stringValue = self.file_name
      @information_field.hidden = false
    end
    
  end
  
  def draggingSourceOperationMaskForLocal(flag)
    return NSDragOperationCopy
  end
  
  def is_file?(sender)
    ! File.directory?(file(sender))
  end
  
  def file(value)
    @file = NSURL.URLFromPasteboard(value.draggingPasteboard).absoluteString.gsub('file://localhost', '')
  end
  
  def file_name
    File.basename(@file)
  end
end