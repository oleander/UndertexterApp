class SubController <  NSView
  
  attr_accessor :information_field, :loading
  
  def initWithFrame(frame)
    super(frame)
    
    @language = {
      1 => :swedish,
      0 => :english 
    }
    
    @default_language = 1
    
    @sub = Sub.new
    
    return self
  end
  
  def language_button(sender)
    @default_language = sender.selectedSegment
  end
  
  def awakeFromNib
    self.registerForDraggedTypes [NSURLPboardType, nil]
    @loading.image = NSImage.imageNamed("activityindicator.gif")
    @loading.animates = true
    
    @queue = Dispatch::Queue.new('net.undertexter.com')
    
    @information_field.hidden = true
    @loading.hidden = false
    
    @queue.async do
      require 'rubygems'
      require 'undertexter'
      require 'movie_searcher'
      require 'dam_lev'
      require 'mimer'
      
      @information_field.hidden = false
      @loading.hidden = true
    end
  end
  
  def draggingEntered(sender)
    return NSDragOperationCopy
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
    return true
  end
  
  def draggingSourceOperationMaskForLocal(isLocal)
    return NSDragOperationCopy
  end
  
  def performDragOperation(sender)
    return true
  end

  def concludeDragOperation(sender)
    @name = is_file?(sender) ? self.file_name : self.dir_name
    
    NSLog("En fil togs emot")
    @information_field.hidden = true
    @loading.hidden = false
    
    @queue.async do
      movie = MovieSearcher.find_by_release_name(@name)
      if movie
        subtitles = Undertexter.find(movie.imdb_id, :language => @language[@default_language])
        if subtitles.any?
          subtitle = subtitles.sort_by{|s| DamLev.distance(s.title, @name)}.first
          NSLog("Texten #{subtitle.movie_title} hittades")
          @information_field.stringValue = movie.title
          self.success!(sender, subtitle)
        else
          NSLog("Ingen sub hittades, testar igen")
          subtitle = Undertexter.find(@name).first
          if subtitle
            @information_field.stringValue = movie.title
            self.success!(sender, subtitle)
          else
            NSLog("Tyvärr, inget hittades!")
            @information_field.stringValue = "Inget hittades"
          end
        end
      else
        NSLog("Inget alls hittades...")
        @information_field.stringValue = "Inget hittades"
      end
      
      @loading.hidden = true
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
    @file = NSURL.URLFromPasteboard(value.draggingPasteboard).absoluteString.gsub('file://localhost', '').gsub(/%20/, ' ')
  end
  
  def file_name
    File.basename(@file, '.*')
  end
  
  def dir_name
    NSLog("Nu ska vi se: #{File.split(@file).last}")
    File.split(@file).last
  end
  
  def success!(sender, subtitle)
    #Genererar en slumpmässig fil för temp
    filename = (0...10).map{65.+(rand(25)).chr}.join.downcase
    
    # Plockar fram rätt absolut sökväg till filen/mappen
    path = (Mimer.identify(@file).mime_type.match(/x-directory/) ? @file : File.dirname(@file)).gsub(/\s+/, '\ ')
    
    # Laddar ner zip/rar-filen
    data = RestClient.get subtitle.url
    
    file = File.new("/tmp/#{filename}", 'w')
    file.write(data)
    file.close
    
    type = Mimer.identify("/tmp/#{filename}")

    if type.mime_type.match(/rar/)
      %x(cd #{path} && #{NSBundle.mainBundle.resourcePath + "/unrar"} e -y /tmp/#{filename})
    elsif type.mime_type.match(/zip/)
      %x(unzip -n /tmp/#{filename} -d #{path})
    end
  end
end