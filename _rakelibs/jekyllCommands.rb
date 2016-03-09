

desc "Serve site locally"
task :serve do
  system "bundle exec jekyll serve --trace"
end

desc "Build jekyll site"
task :build do
#  system "bundle exec jekyll build --profile"
  system "bundle exec jekyll build --trace"
end

