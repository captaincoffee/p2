
$posts_dir       = "_posts"
$default_ext    = "md"
$collection_dir = "_authors"

$categories = [ "cat1", "cat2", "cat3", "cat4", "cat5", "cat6", "cat7", "cat8", "cat9", "cat10"]
$tags       = ["tag1", "tag2", "tag3", "tag4", "tag5", "tag6", "tag7" ]

$corpus     = File.readlines("_dict/corpus.txt").map {|i| i.chomp}

$nameSeparator = "****"

default_post_front = { 'layout' => 'post', 'title'  => 'default title' }

desc "Create a new post. Usage rake post [my title] or rake post (defaults to 'index')"
task :post, :title do |t, args|

  if args.title
    title = args.title
  else
    title = get_dummy_title
  end

  date = time_rand Time.local(2010, 1, 1)

  y = sprintf("%04d", date.year)
  m = sprintf("%02d", date.month)
  d = sprintf("%02d", date.day)

  filename = "#{posts_dir}/#{y}-#{m}-#{d}-#{title.to_url}.#{$default_ext}"

  front = default_post_front.merge({
      'title' => "#{title.gsub(/&/,'&amp;')}",
      'date'  => "#{date.strftime('%Y-%m-%d %H:%M:%S %:z')}",
      #'authors' =>"[#{get_authors}]",
      # 'categories' => "[#{get_categories}]",
      'tags' => "[#{get_tags}]"
  })

  content = get_content( 4, 30 )

  create_file(filename, front, content)
end

# "Create a new collection item."
def create_collection(name)

  nameArray = name.split($nameSeparator)

  firstName = nameArray.first
  lastName  = nameArray.last
  fullName  = "#{firstName} #{lastName}"
  slug      = fullName.to_url

  filename = "#{$collection_dir}/#{slug}.#{$default_ext}"

  front = {
      'firstName' => "#{firstName}",
      'lastName' => "#{lastName}",
      'slug'  => "#{slug}",
      'tags' => "[#{get_tags(4, 6)}]"
  }

  content = get_content()

  create_file(filename, front, content)
end

desc "Generate multiple posts or pages"
task :generate, :type, :number do |t, args|

  args.with_defaults(:type => 'post', :number => 10)

  case args.type
  when 'post'
    task = :post
  when 'col'
    task = :page
  end

  for i in 1..args.number do
    title = get_dummy_title
    Rake::Task[task].invoke(title)
    Rake::Task[task].reenable
  end
end

desc "Generate authors collection"
task :genauthors, :number do |t, args|
  puts "### Creating authors collection"
  set_authors_list
  args.with_defaults(:number => $authors.length)
  for i in 1..args.number do
    create_collection($authors[i-1])
  end
end

desc "Create a text file with authors"
task :authors, :length do |t, args|

  args.with_defaults(:length => 10)
  length   = args.length.to_i
  puts "### Creating a #{length} authors pool"

  filename = "_dict/authors.txt"
  fNames   = File.readlines("_dict/first-names.txt").map {|i| i.chomp}
  lNames   = File.readlines("_dict/last-names.txt").map {|i| i.chomp}

  names = []

  for i in 1..length do
    fn = fNames.sample(1).join.capitalize
    ln = lNames.sample(1).join.capitalize
    names.push("#{fn}#{$nameSeparator}#{ln}")
  end

  open(filename, 'w') do |f|
    f.puts names
  end
end

def create_file(filename, front, content = "default content")
  d1( "Creating new file: #{filename}" )
  open(filename, 'w') do |f|
    f.puts "---"
    front.each{ |key,value| f.puts "#{key}: #{value}" }
    f.puts "---"
    f.puts ""
    f.puts content
  end
end

def get_content( paraNumber = 2, paraLength = 20)
  prng = Random.new
  content = prng.rand(1...paraNumber).times.map do |c|
    $corpus.sample(prng.rand(1...paraLength)).join(' ').capitalize
  end.join(".\n\n")
  content
end

def get_dummy_title( length = 5 )
  $corpus.sample(length).join(' ').capitalize
end

def get_categories
  $categories.sample( 1 + rand($categories.length) ).join(', ')
end

def get_tags( min = 1, max = nil )
  if max.nil?
    max = $tags.length
  else
    max = 2
  end
  $tags.sample( min + rand(max) ).join(', ')
end

def set_authors_list
  $authors = File.readlines("_dict/authors.txt").map {|i| i.chomp}
end

def get_authors
  set_authors_list
  $authors.sample( 1 + rand(3) ).map{|e| e.split($nameSeparator).join(' ').to_url }.join(', ')
end

def get_stdin(message)
  print message
  STDIN.gets.chomp
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

class Rake::Task
  def execute_with_benchmark(*args)
    bm = Benchmark.measure { execute_without_benchmark(*args) }
    puts "   #{name} --> #{bm}"
  end

  alias_method :execute_without_benchmark, :execute
  alias_method :execute, :execute_with_benchmark
end

desc "list tasks"
task :list do
  puts "Tasks: #{(Rake::Task.tasks - [Rake::Task[:list]]).join(', ')}"
  puts "(type rake -T for more detail)\n\n"
end

task :clean do
  puts "### Cleaning"
  rm_rf [ Dir.glob("_authors/*.md"), Dir.glob("_posts/*.#{$default_ext}") ]
end


task :go do

  authors = 5
  posts = 10

  Rake::Task[:clean].invoke
#  Rake::Task[:authors].invoke(authors)
#  Rake::Task[:genauthors].invoke()
  Rake::Task[:generate].invoke('post', posts)
#  Rake::Task[:build].invoke()

  puts "authors: #{authors} - posts: #{posts}"
end

