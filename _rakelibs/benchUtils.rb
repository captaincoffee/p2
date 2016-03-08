
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

def safe_clean_folder( elementsFolderFullPath )
  d2("+++ safe_clean_folder : #{elementsFolderFullPath}")
  folderFiles = Dir.glob("#{elementsFolderFullPath}/*")
  d2("cleaning #{folderFiles}")
  # check that each file can be removed safely
  folderFiles.each do |file|
    raise "### safe_clean_folder - Wrong path for file #{file}" if !child?($rootPath, file)
  end
  ################ BEWARE THIS IS DANGEROUS !!!!
  rm_rf [ folderFiles ], :verbose => true, :secure => true
end

# ensure that a folder/file is in the project path and exists
# root and target must be full path
# inspired by jekyll code
def child?(root, target)
  isChild = File.exist?(target) && inRootPath?(root, target)
  d2( "isChild? #{isChild }- root: #{root} - target: #{target}" )
  isChild
end

# ensure a target folder/file in in root path
def inRootPath?(root, targetFullPath)
  inRootPath = File.realpath(targetFullPath).start_with?(root)
  d2("inRootPath? : #{inRootPath} - root: #{root} - targetFullPath: #{targetFullPath}")
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

