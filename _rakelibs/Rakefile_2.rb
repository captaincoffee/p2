require "rubygems"
require "yaml"
require "stringex"
require 'benchmark'

$rootPath = __dir__

configPath = File.join($rootPath, '_config.yml')
configYaml = YAML::load_file(configPath)
$collectionConfig = configYaml["collections"]

saveFolder  = "#{$rootPath}/_save"

# random articles per collection boundaries
minRandomArticles = 1
maxRandomArticles = 3

# in order to do clean benchmarks, we strictly limit numbers
$maxNbCollections = 2
$maxNbCategoriesPerCollection = 15
$maxNbArticlesPerCat = 10

$totalNumberOfTags = 6
$maxTagsOnArticles = 2

$articleContentMaxParaNb = 4
$articleContentMaxParaLength = 50

$articleNumber = 0 # total article counter

$debug1 = false
$debug2 = true

task :default => [:dummy]

desc "Save collections"
task :save do
  puts "++++++++++++++ Saving existing collections"
  # mave a save dir if it doesn't exist
  FileUtils.mkdir(saveFolder) unless File.exist?(saveFolder)

  $collectionConfig.each do |collection|
    collectionSlug = collection[0]
    puts "\n\n Saving collection #{collectionSlug}"
    collectionFolder = "#{$rootPath}/_#{collectionSlug}"
    destinationPath = "#{saveFolder}/_#{collectionSlug}"

    puts "removing destination if it exists : #{destinationPath}"
    FileUtils.remove_dir(destinationPath) if File.exist?(destinationPath)

    puts "Copying #{collectionFolder} to #{saveFolder}"
    FileUtils.cp_r( collectionFolder, saveFolder )
  end
end

desc "Creates dummy articles"
task :dummy do
  d1("++++++++++++++ Creates dummy articles")

  totalNbCollections = 0

  clean_collections_folders
  clean_collections_indexes_folders

  $collectionConfig.first($maxNbCollections).each do |collection|

    $categoryNumber = 0

    collectionSlug = collection[0]
    d2(">>>>Creating dummies for collection #{collectionSlug}")
    collectionFolder = "#{$rootPath}/_#{collectionSlug}"

    d1("creates #{$maxNbArticlesPerCat} articles in each collection's category")
    collectionCategories = collection[1]["categories"]

    collectionCategories.first($maxNbCategoriesPerCollection).each do |category|

      categorySlug   = category["slug"]
      categoryFolder = "#{collectionFolder}/#{categorySlug}"
      d1("Creates destination folder for this category's articles")
      FileUtils.mkdir(categoryFolder)
      $maxNbArticlesPerCat.times.map do |index|
          d1("creating article number #{index} for #{categorySlug}")
          create_article( collection, category )
      end

      d1("Ensure category index exists")
      collectionIndexesFolder = "#{$rootPath}/#{collectionSlug}"
      categoryIndexFile = "#{collectionIndexesFolder}/#{categorySlug}.html"

      if !File.exist?(categoryIndexFile)
        d1("categoryIndexFile #{categoryIndexFile} doesn't exists create it !")
        open(categoryIndexFile, 'w') do |f|
          f.puts "---"
          f.puts "---"
          f.puts "{% include components/category-page.html %}"
        end
      end
      $categoryNumber += 1
      d1(">>>>>>>>>>> END category #{categorySlug}")
    end

    d1("Ensure collections index exists")
    collectionIndexesFolder = "#{$rootPath}/#{collectionSlug}"
    collectionIndexFile = "#{collectionIndexesFolder}/index.html"

    if !File.exist?(collectionIndexFile)
      d1("collectionIndexFile #{collectionIndexFile} doesn't exists create it !")
      open(collectionIndexFile, 'w') do |f|
        f.puts "---"
        f.puts "---"
        f.puts "{% include components/collection-page.html %}"
      end
    end
    d2("created #{$categoryNumber} categories")
    d1(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> END collection #{collectionSlug}\n")

  end
  d2("Created #{$articleNumber} articles")
end

def clean_collections_folders
  $collectionConfig.each do |collection|
    collectionSlug = collection[0]
    collectionFolder = "#{$rootPath}/_#{collectionSlug}"
    d1("removing existing folders in : #{collectionFolder}")
    folderList = Dir.glob("#{collectionFolder}/**") { |folder|
        d1("-----> removing #{folder}")
        FileUtils.remove_dir(folder)
    }
  end
end

def clean_collections_indexes_folders
  $collectionConfig.each do |collection|
    collectionSlug = collection[0]
    collectionIndexesFolder = "#{$rootPath}/#{collectionSlug}"
    d1("removing existing collections and categories indexes in : #{collectionIndexesFolder}")
    folderList = Dir.glob("#{collectionIndexesFolder}/**") { |folder|
        d1("-----> removing #{folder}")
        FileUtils.remove_dir(folder)
    }
  end
end

$articleTypes = configYaml["articleTypes"]
$corpus       = File.readlines("_dict/corpus.txt").map {|i| i.chomp}
$tags         = $corpus.sample($totalNumberOfTags)

def create_article(collection, category)
  collectionSlug   = collection[0]
  collectionFolder = "#{$rootPath}/_#{collectionSlug}"
  categorySlug   = category["slug"]
  categoryFolder = "#{collectionFolder}/#{categorySlug}"

  d1("Creating new article in #{categoryFolder}")

  articleType = $articleTypes.sample
  articleTypeSlug = articleType["slug"]
  d1(" --> creating a #{articleTypeSlug} type")

  date = time_rand Time.local(2010, 1, 1)

  title = get_dummy_title
  slug = title.to_url

  filePath = "#{categoryFolder}/#{slug}.html"

  d1("filePath : #{filePath}")

  front = {
      'title' => "#{title}",
      'date'  => "#{date.strftime('%Y-%m-%d %H:%M:%S %:z')}",
      'type' => "#{articleTypeSlug}",
      'tags' => "[#{get_tags}]"
  }

  # content = get_content( $articleContentMaxParaNb, $articleContentMaxParaLength )
  content = "<p>Toto</p>"

  open(filePath, 'w') do |f|
    f.puts "---"
    front.each{ |key,value| f.puts "#{key}: #{value}" }
    f.puts "---"
    f.puts ""
    f.puts content
  end

  $articleNumber += 1

end

def get_dummy_title( length = 5 )
  $corpus.sample(length).join(' ').capitalize
end

def get_tags( min = 3, max = $maxTagsOnArticles )
  tags = $tags.sample( min + rand(max) ).join(', ')
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

def d1(msg)
  if $debug1 == true
    puts msg
  end
end

def d2(msg)
  if $debug2 == true
    puts msg
  end
end



class Rake::Task
  def execute_with_benchmark(*args)
    bm = Benchmark.measure { execute_without_benchmark(*args) }
    puts "   #{name} --> #{bm}"
  end

  alias_method :execute_without_benchmark, :execute
  alias_method :execute, :execute_with_benchmark
end
