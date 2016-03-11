
def create_categories_pages( collectionName )
  # get collections datas
  $config = YAML::load_file($configPath)
  collectionDatas = $config["collections"][collectionName]
  collectionCategories = collectionDatas["categories"]
  # get folder list in "_#{collectionName}"
  folders = Dir.entries("_#{collectionName}").reject{|entry| [".", ".."].include?(entry) }
  # work early with absolute path
  collectionFolderFullPath = File.join($rootPath, collectionName)
  # check for path validity
  inRootPath?($rootPath, collectionFolderFullPath)
  # for each folder
  folders.each do |folder|
    categoryPageFullPath = "#{collectionFolderFullPath}/#{folder}.html"
    if !File.exist?(categoryPageFullPath)
      categoryDatas = collectionCategories.select{|cat| cat["slug"]==folder }.first
      pageTitle = "#{collectionDatas['name']} - #{categoryDatas['name']}"
      front = {'title' => pageTitle}
      content = "{% include components/category-page.html %}"
      create_file(categoryPageFullPath, front, content)
    end
  end
end

def create_file(filename, front, content)
  open(filename, 'w') do |f|
    f.puts "---"
    front.each{ |key,value| f.puts "#{key}: #{value}" }
    f.puts "---"
    f.puts ""
    f.puts content
  end
end

# Get github config from jekyll *_config.yml* file
def githubGetConfig
  @config = YAML::load_file($configPath)
  g = @config['github']
  ['user', 'repository', 'remoteName'].each do |key|
    raise "Please set Github.#{key} in jekyll _config.yml" if !g[key]
  end
  @config['github']
end

# Check if a working folder has a correct git setup
# Source and generated site are versioned in two different branches
def githubCheckSetup(branch, githubConfig)
    branchPath = getBranchPath(branch)
    # do we have a git repository in our folder ?
    isInitialized = isGitRepo?(branchPath)
    # is it set to correct remote ?
    asCorrectRemote = asCorrectRemote?(branchPath, githubConfig)
    # is on the right branch
    isOnRightBranch = isOnRightBranch?(branchPath, branch)
end

def githubPublish(branch, githubConfig)
  branchPath = getBranchPath(branch)
  # stage all files to commit
  g = Git.open(branchPath)
  g.add(:all=>true)
  # ask user for a commit message
  commitMsg = ask("Commit message for branch #{branch['name']}: ")
  if commitMsg == ''
    commitMsg = "Code update #{Time.now.utc}"
  end
  # commit
  g.commit_all(commitMsg)
  # push
  g.push(githubConfig['remoteName'], branch['name'])
end

# returns full path for a given branch
def getBranchPath( branch )
  path = "#{$rootPath}/#{branch['path']}"
  child?($rootPath, path) # security check
  path
end

# Check if a git repository is set in path
# if not ask user if we init one
def isGitRepo?( path )
  begin
    d1("Checking if #{path} is a git repo")
    repo = Git.open(path)
  rescue => e
    d1("No initialized git repository in #{path} : #{e}")
    abort("rake aborted!") if ask("Do you want to initialize a new git repository in #{path} ?", ['y', 'n']) == 'n'
    repo = Git.init(path)
  end
end

# Check if our remote is correctly set
# see _config.yml - github variables for setup
# remote name default is *origin*
# remote uri default is *git@github.com:userName/repositoryName.git*
#
# if remote is not ok, ask user if we set the right one
# BEWARE ! If an *origin* remote exists, it is removed !
def asCorrectRemote?(path, githubConfig)
  d1("Testing remote for #{path}")
  targetUrl = "git@github.com:#{githubConfig['user']}/#{githubConfig['repository']}.git"
  d1("Target url is #{targetUrl}")
  g = Git.open(path)
  remoteUrl = g.remote(githubConfig['remoteName']).url
  d1("g.remote(#{githubConfig['remoteName']}).url #{remoteUrl}")
  targetUrl = "git@github.com:#{githubConfig['user']}/#{githubConfig['repository']}.git"

  if remoteUrl == targetUrl
    remoteUrl
  elsif !remoteUrl
    d1("++++++ Not remote set for #{githubConfig['remoteName']}")
    abort("rake aborted!") if ask("Do you want to set remote to **#{githubConfig['remoteName']} #{targetUrl}** ?", ['y', 'n']) == 'n'
    remote = g.add_remote(githubConfig['remoteName'], targetUrl)
  else
    d1("++++++ Remote #{githubConfig['remoteName']} ALREADY set with url #{remoteUrl}")
    abort("rake aborted!") if ask("Do you want to replace remote to **#{githubConfig['remoteName']} #{targetUrl}** ?", ['y', 'n']) == 'n'
    g.remote(githubConfig['remoteName']).remove
    remote = g.add_remote(githubConfig['remoteName'], targetUrl)
  end
end

# Check if out two branches are on the right branches
# see _config.yml - github variables for setup
def isOnRightBranch?(path, branch)
  d2("Testing branch for #{path}")
  g = Git.open(path)
  branchName = g.branch(branch['name'])
  d2("Current branch on #{path} is #{branchName}")
  targetName = branch["name"]
  d2("target name is #{targetName}")

  if branchName == targetName
    branchName
  else
    abort("rake aborted! Current branch on #{path} is #{branchName} supposed to be #{targetName}") if ask("Do you want to switch branch to #{targetName} ?", ['y', 'n']) == 'n'

    # It seems that there is a bug for branch creation / checkout
    # branchName = g.branch(targetName).create
    # checkout = g.branch(branchName).checkout
    # d2("g.branch(targetName) #{branchName}")
    # d2("g.checkout(branchName) #{checkout}")

    # so for now we use a direct system call
    cd "#{path}" do
      branchCreated = system "git checkout -b #{targetName}"
      d2("Checked out #{targetName} branch (result code : #{branchCreated})")
    end
  end
end


# ensure that a folder/file is in the project path and exists
# root and target must be full path
def child?(root, target)
  isChild = File.exist?(target) && inRootPath?(root, target)
end

# ensure a target folder/file in in root path
def inRootPath?(root, targetFullPath)
  inRootPath = File.realpath(targetFullPath).start_with?(root)
  raise "NOT IN ROOT PATH" if !inRootPath
  inRootPath
end

def get_stdin(message)
  print message
  STDIN.gets.chomp
end

def ask(message, valid_options=nil)
  if valid_options
    answer = get_stdin("#{message} #{valid_options.to_s.gsub(/"/, '').gsub(/, /,'/')} ") while !valid_options.include?(answer)
  else
    answer = get_stdin(message)
  end
  answer
end

# debug
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
