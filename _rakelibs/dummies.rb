require "stringex"

def create_elements( type = 'post', numberOf = 1, clean = false, collectionName = "methods" )
  d1("## Create_elements : type=#{type} - numberOf=#{numberOf} - clean=#{clean} - collectionName=#{collectionName}")
  currentCounter = 0
  $config        = YAML::load_file($configPath)
  $categoriesPool= get_categories_pool(collectionName)

  case type
    when "post"
      elementsFolder = $posts_dir
    when "page"
      elementsFolder = $pages_dir
    when "collection"
      elementsFolder  = "_#{collectionName}"
      collectionDatas = $config["collections"][collectionName]
      categories      = $categoriesPool
      types           = $config["articleTypes"]
    else
      raise "### Wrong element type. Can be 'post' or 'page'. Passed : #{type}"
  end

  # work early with absolute path
  elementsFolderFullPath = File.join($rootPath, elementsFolder)
  d2("Working in #{elementsFolderFullPath}")
  # check for path validity
  inRootPath?($rootPath, elementsFolderFullPath)

  # clean old elements ?
  if clean == true
    safe_clean_folder( elementsFolderFullPath )
  end

  d1("------------------------------------- Creating #{numberOf} #{type}")
  for i in 1..numberOf do

    d2("Creating ##{i} #{type}")

    title = get_dummy_title
    date  = time_rand Time.local(2010, 1, 1)

    fileFullPath = elementsFolderFullPath
    filename = "#{title.to_url}.#{$default_ext}"

    case type
      when "post"
        y = sprintf("%04d", date.year)
        m = sprintf("%02d", date.month)
        d = sprintf("%02d", date.day)
        filename = "#{y}-#{m}-#{d}-#{title.to_url}.#{$default_ext}"
      when "page"
        # this is default behavior
      when "collection"
        categoryFolder = categories.sample(1).first['slug']
        d1("categoryFolder = #{categoryFolder}")
        fileFullPath = "#{elementsFolderFullPath}/#{categoryFolder}"
    end

    # ensure that elementsFolderFullPath exists
    unless File.directory?(fileFullPath)
      d1("creating #{fileFullPath}")
      FileUtils.mkdir_p(fileFullPath)
    end

    filenameFullPath = "#{fileFullPath}/#{filename}"

    front = {
      'title' => "#{title.gsub(/&/,'&amp;')}",
      'date'  => "#{date.strftime('%Y-%m-%d %H:%M:%S %:z')}"
    }

    case type
      when "post"
        tags = get_tags()
        front["tags"] = tags
      when "page"
        #
      when "collection"
        tags          = get_tags()
        front["tags"] = tags
        itemType      = types.sample(1).first
        front["type"] = itemType["slug"]
        front["image_path"] = get_image()
    end

    excerpt = get_content( 2, 15 )
    excerpt_separator = $config['excerpt_separator']
    body = get_content( 4, 30 )

    content = "#{excerpt}\n#{excerpt_separator}\n#{body}"

    create_file(filenameFullPath, front, content)
    $elementCounter += 1
    currentCounter += 1

  end

  d1( "created #{currentCounter} item of type #{type}" )
end

def create_categories_pages( collectionName )
  d2("## Creating Categories pages for #{collectionName}")
  # get folder list in "_#{collectionName}"
  folders = Dir.entries("_#{collectionName}").reject{|entry| [".", ".."].include?(entry) }
  d2("Listed categories folders #{folders}")
  # work early with absolute path
  collectionFolderFullPath = File.join($rootPath, collectionName)
  d2("Working in #{collectionFolderFullPath}")
  # check for path validity
  inRootPath?($rootPath, collectionFolderFullPath)
  # for each folder
  categoriesCount = 0
  folders.each do |folder|
    categoryPageFullPath = "#{collectionFolderFullPath}/#{folder}.html"
    if !File.exist?(categoryPageFullPath)
      d1("categoryPageFullPath #{categoryPageFullPath} doesn't exists create it !")
      categoriesCount += 1
      open(categoryPageFullPath, 'w') do |f|
        f.puts "---"
        f.puts "---"
        f.puts "{% include components/category-page.html %}"
      end
    end
  end
  d2("## Created #{categoriesCount} Categories for #{collectionName}")
end

def clean_categories_pages(collectionName)
  collectionFolderFullPath = File.join($rootPath, collectionName)
  d2("Working in #{collectionFolderFullPath}")
  # check for path validity
  inRootPath?($rootPath, collectionFolderFullPath)
  # find categories pages
  pages = FileList.new("#{collectionFolderFullPath}/*")
  pages.exclude('**/index.html')
  d2("Pages selected for deletion : #{pages}")
  # remove all files in #{collectionName} folder except index.html
  # check that each file can be removed safely
  pages.each do |file|
    raise "### safe_clean_folder - Wrong path for file #{file}" if !child?($rootPath, collectionFolderFullPath)
    d1("#{file} can be safely removed")
  end
  ################ BEWARE THIS IS DANGEROUS !!!!
  d2(" ++++++++++++++++++ REMOVING")
  rm_rf [ pages ], :verbose => true, :secure => true
end
