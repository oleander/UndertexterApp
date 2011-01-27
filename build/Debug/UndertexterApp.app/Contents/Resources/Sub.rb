require 'Growl'

class Sub
  def initialize(args)
    @sender, @path = args[:sender], args[:path]
  end
  
  def success!(subtitle)    
    #Genererar en slumpmässig fil för temp
    filename = self.generate_file_name(15)
    
    # Laddar ner subtitlen och sparar till angiven fil
    download_and_save_to_disk(filename, subtitle)
    
    # Packar upp filen till angiven url {path}
    unpack(filename, path)
  end
  
  # Genererar en sträng med {n} tecken
  def generate_file_name(n)
    (0...n).map{65.+(rand(25)).chr}.join.downcase
  end
  
  # private
  
  def file
    @sender.nil? ? @path : NSURL.URLFromPasteboard(@sender.draggingPasteboard).absoluteString.gsub('file://localhost', '').gsub(/(%20)/, ' ')
  end
  
  # Retunerar den absolute länkvägen till filen som angivits
  def path
    is_directory? ? file : File.dirname(file)
  end
  
  def is_directory?
    File.directory?(file)
  end
  
  def unrar(path, filename)
    %x(cd #{path.gsub(/\s+/, '\ ')} && #{NSBundle.mainBundle.resourcePath + "/unrar"} e -y /tmp/#{filename})
  end
  
  def unzip(path, filename)
    %x(unzip -n /tmp/#{filename} -d #{path.gsub(/\s+/, '\ ')})
  end
  
  # Laddar ner zip/rar-filen och sparar till disk
  def download_and_save_to_disk(filename, subtitle)
    data = RestClient.get subtitle.url

    file = File.new("/tmp/#{filename}", 'w')
    file.write(data)
    file.close
  end
  
  def unpack(filename, path)
    type = Mimer.identify("/tmp/#{filename}")
    
    if type.mime_type.match(/rar/)
      unrar(path, filename)
    elsif type.mime_type.match(/zip/)
      unzip(path, filename)
    else
      Growl.send(message: "Du har angivit en filtyp som inte finns: #{type.mime_type}", title: "Något gick fel")
    end
  end
  
  def file_name
    File.basename(file, '.*')
  end
  
  def dir_name
    File.split(file).last
  end
  
  # Är det en mapp eller fil som har skickats med?
  def working_data
    self.is_directory? ? self.dir_name : self.file_name
  end
end
