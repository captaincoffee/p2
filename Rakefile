require "rubygems"
require "stringex"
require 'git' # code https://github.com/schacon/ruby-git
              # API http://www.rubydoc.info/gems/git/1.2.9.1/Git

require_relative '_rakelibs/libs.rb'

$debug = true

$rootPath = __dir__
d("Current directory : #{$rootPath}")

$configPath = File.join($rootPath, '_config.yml')

$posts_dir      = "_posts"
$pages_dir      = "_pages"
$collectionsNames = ['manage', 'materials', 'methods']

task :default => [:list]

desc "Create pages for collection's categories"
task :catpages do
  $collectionsNames.each do |collectionName|
    create_categories_pages( collectionName )
  end
end

desc "Check if github setup is ok"
task :checkGithub do
    githubConfig = githubGetConfig
    branches     = githubConfig['branches']
    branches.each do |branch|
      githubCheckSetup(branch, githubConfig)
    end
end

desc "Publish your work in code and site's branches"
task :publish do
  # build site
  Rake::Task[:build].invoke

  # check git config
  Rake::Task[:checkGithub].invoke
  # publish both branches
  githubConfig = githubGetConfig
  branches     = githubConfig['branches']
  branches.each do |branch|
    githubPublish(branch, githubConfig)
  end
end

desc "Serve site locally"
task :serve do
  # check if we need to create categories pages
  Rake::Task[:catpages].invoke
  system "bundle exec jekyll serve --trace"
end

desc "Build jekyll site"
task :build do
  # check if we need to create categories pages
  Rake::Task[:catpages].invoke
  system "bundle exec jekyll build --trace"
end

desc "list tasks"
task :list do
  puts "Tasks: #{(Rake::Task.tasks - [Rake::Task[:list]]).join(', ')}"
  puts "(type rake -T for more detail)\n\n"
end

