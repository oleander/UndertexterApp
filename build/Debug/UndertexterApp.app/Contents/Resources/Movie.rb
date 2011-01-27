#
#  Movie.rb
#  UndertexterApp
#
#  Created by Linus Oleander on 2011-01-27.
#  Copyright (c) 2011 Chalmers. All rights reserved.
#

class Movie
  attr :movie, :subtitle
  
  def initialize(args)
     @movie, @subtitle = args[:movie], args[:subtitle]
  end
  
  def self.find(name, language)
    movie = MovieSearcher.find_by_release_name(name)
    
    if movie
      subtitles = Undertexter.find(movie.imdb_id, language: language)
      subtitle = subtitles.sort_by{|s| DamLev.distance(s.title, name)}.first if subtitles.any?
    end
    Movie.new(movie: movie, subtitle: subtitle)
  end
end
