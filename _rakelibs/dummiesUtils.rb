corpusFile = "#{__dir__}/dictionaries/corpus.txt"
$corpus = File.readlines(corpusFile).map {|i| i.chomp}

def get_dummy_title( length = 5 )
  $corpus.sample(length).join(' ').capitalize
end

def get_categories_pool(collectionName)
  caetegoriesForCollection = $config['collections'][collectionName]['categories']
  categories = caetegoriesForCollection.sample($numberOfCategories)
  d1("++++++++++ categories poll #{$numberOfCategories} : #{categories}")
  categories
end

def get_tags_pool(numberOfTags = $numberOfTags)
  tags = $corpus.sample(numberOfTags)
  d2("++++++++++ tags poll #{numberOfTags} : #{tags}")
  tags
end

def get_tags( min = $minTagsPerItem, max = $maxTagsPerItem )
  prng = Random.new
  tagsArray = $tagsPool.sample(prng.rand(min...max))
  tags = "[#{tagsArray.join(', ')}]"
  d1("assigned TAGS : #{tags}")
  return tags
end

def get_content( paraNumber = 2, paraLength = 20)
  prng = Random.new
  content = prng.rand(1...paraNumber).times.map do |c|
    $corpus.sample(prng.rand(1...paraLength)).join(' ').capitalize
  end.join(".\n\n")
  content
end

# > time_rand
# => 1977-11-02 04:42:02 0100
# > time_rand Time.local(2010, 1, 1)
# => 2010-07-17 00:22:42 0200
# > time_rand Time.local(2010, 1, 1), Time.local(2010, 7, 1)
# => 2010-06-28 06:44:27 0200
def time_rand from = 0.0, to = Time.now
  Time.at(from + rand * (to.to_f - from.to_f))
end

def create_file(filename, front, content = "<h1>Toto</h1>")
  d2( "Creating new file: #{filename}" )

  open(filename, 'w') do |f|
    f.puts "---"
    front.each{ |key,value| f.puts "#{key}: #{value}" }
    f.puts "---"
    f.puts ""
    f.puts content
  end
end

