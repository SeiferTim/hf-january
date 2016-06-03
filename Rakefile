require 'bundler'
require 'open3'
require './ZipFileGenerator.rb'

task :default => :serve


desc "Builds the Project for deployment"
task :build_proj do
  FileUtils.rm_r(Dir.glob('./january/export'))
  FileUtils.rm_r(Dir.glob('./january-site/january.swf'))
  FileUtils.rm_r(Dir.glob('./january-site/downloads/january-win.zip'))
  FileUtils.rm_r(Dir.glob('./january-site/downloads/january-mac.zip'))
  puts "Building Project..."
  results, error, status = Open3.capture3("haxelib", "run", "flixel-tools", "buildprojects", "flash", "-dir", ".")
  puts results
  if !status.success?
    puts "ERROR! - #{error}"
    exit 1
  end

  results, error, status = Open3.capture3("haxelib", "run", "flixel-tools", "buildprojects", "windows", "-dir", ".")
  puts results
  if !status.success?
    puts "ERROR! - #{error}"
    exit 1
  end
  results, error, status = Open3.capture3("haxelib", "run", "flixel-tools", "buildprojects", "mac", "-dir", ".")
  puts results
  if !status.success?
    puts "ERROR! - #{error}"
    exit 1
  end
  puts "Done Building Project...";
  puts Dir.entries('.').select {|entry| File.directory? File.join('.',entry) and !(entry =='.' || entry == '..') }
 

end

desc "Build the site with Jekyll"
task :build_site do
  jekyll('build')
end

desc "For Testing, just build the project and serve the site to localhost:4000"
task :serve => [:build_proj, :serve_site]

desc "Just serves the site, does not rebuild the project"
task :serve_site do
  jekyll('serve')
end

desc "Build and Deploy the entire site"
task :deploy => [:build_proj, :build_site]

def jekyll(opts = '')
  sh 'jekyll ' + opts + ' -s january-site'
end
