require 'rubygems'
require 'bundler'
require 'bundler/setup'

require 'rake/clean'
require 'flashsdk'

def configure_task t
  t.source_path             << "lib/bulkloader-rev-282"
  t.library_path            << 'assets/player_assets.swc'
  t.library_path            << 'lib/OSMF.swc'
  t.library_path            << 'lib/tweener_v1.33.74.swc'
  t.library_path            << 'lib/corelib.swc'
end

##
# Set USE_FCSH to true in order to use FCSH for all compile tasks.
#
# You can also set this value by calling the :fcsh task 
# manually like:
#
#   rake fcsh run
#
# These values can also be sent from the command line like:
#
#   rake run FCSH_PKG_NAME=flex3
#
# ENV['USE_FCSH']         = true
# ENV['FCSH_PKG_NAME']    = 'flex4'
# ENV['FCSH_PKG_VERSION'] = '1.0.14.pre'
# ENV['FCSH_PORT']        = 12321

##############################
# Debug

# Compile the debug swf
mxmlc "bin/rioflashclient-debug.swf" do |t|
  t.input = "src/Main.as"
  t.debug = true
  t.strict                                = false
  t.define_conditional                    << "CONFIG::LOGGING,false"
  t.define_conditional                    << "CONFIG::FLASH_10_1,false"
  t.static_link_runtime_shared_libraries  = true
  configure_task t
end

desc "Compile and run the debug swf"
flashplayer :run => "bin/rioflashclient-debug.swf"

##############################
# Test

library :asunit4

# Compile the test swf
mxmlc "bin/rioflashclient-test.swf" => :asunit4 do |t|
  t.input = "test/runner/TestRunner.as"
  t.source_path << 'test'
  t.debug = true
  t.strict                                = false
  t.define_conditional                    << "CONFIG::LOGGING,false"
  t.define_conditional                    << "CONFIG::FLASH_10_1,false"
  t.static_link_runtime_shared_libraries  = true
  configure_task t
end

desc "Compile and run the test swf"
flashplayer :test => "bin/rioflashclient-test.swf"

##############################
# SWC

compc "bin/rioflashclient.swc" do |t|
  t.input_class = "Main"
  t.source_path << 'src'
  configure_task t
  t.strict                                = false
  t.define_conditional                    << "CONFIG::LOGGING,false"
  t.define_conditional                    << "CONFIG::FLASH_10_1,false"
  t.static_link_runtime_shared_libraries  = true
end

desc "Compile the SWC file"
task :swc => 'bin/rioflashclient.swc'

##############################
# DOC

desc "Generate documentation at doc/"
asdoc 'doc' do |t|
  t.doc_sources << "src"
  t.exclude_sources << "test/runner/TestRunner.as"
end

##############################
# DEFAULT
task :default => :run

#Dir['tasks/**/*.rake'].each { |file| load file }

namespace :test do
  desc 'Starts the test server'
  task :start_server do
    puts "Starting test server test server..."
    system("./test_server.rb &")
  end

  desc 'Copies the fixtures to bin directory'
  task :create_fixtures_symlink do
    require 'fileutils'
    root_dir = File.expand_path(File.dirname(__FILE__))
    source_dir = File.join(root_dir, 'test', 'fixtures')
    symlink = File.join(root_dir, 'bin')

    FileUtils.ln_sf source_dir, symlink
  end

  desc 'Compile run the test harness'
  mxmlc :runner => [:start_server, :create_fixtures_symlink] do |t|
    t.source_path << 'test'
    t.source_path << 'src'
    t.debug                                 = true
    t.input                                 = 'test/runner/TestRunner.as'
    t.library_path                          << 'test/lib/flexunit-aircilistener-4.1.0.swc'
    t.library_path                          << 'test/lib/flexunit-cilistener-4.1.0.swc'
    t.library_path                          << 'test/lib/flexunit-core-as3-4.1.0.swc'
    t.library_path                          << 'test/lib/flexunit-uilistener-4.1.0.swc'
    t.default_size                          = '1024 768'
    t.static_link_runtime_shared_libraries  = true
    configure_task t
  end
end

desc 'Runs both test server and test runner'
task :test => 'runner' do
  root_dir = File.expand_path(File.dirname(__FILE__))
  if File.exist?(File.join(root_dir, 'tests_failed.txt'))
    exit 1
  else
    exit 0
  end
end

desc 'Compile the optimized deployment'
mxmlc :compile do |t|
 t.input                                 = 'src/Main.as'
 t.strict                                = true
 t.define_conditional                    << "CONFIG::LOGGING,false"
 t.define_conditional                    << "CONFIG::FLASH_10_1,false"
 t.static_link_runtime_shared_libraries  = true
end

desc 'Compile and run the test harness for CI'
mxmlc :ci => ['test:start_server', 'test:create_fixtures_symlink'] do |t|
  t.input                                 = 'test/runner/TestRunner.as'
  t.library_path                          << 'test/lib/flexunit-aircilistener-4.1.0.swc'
  t.library_path                          << 'test/lib/flexunit-cilistener-4.1.0.swc'
  t.library_path                          << 'test/lib/flexunit-core-as3-4.1.0.swc'
  t.library_path                          << 'test/lib/flexunit-uilistener-4.1.0.swc'
  t.default_size                          = '1024 768'
  t.static_link_runtime_shared_libraries  = true
end

task :cruise => :ci do
  root_dir = File.expand_path(File.dirname(__FILE__))
  if File.exist?(File.join(root_dir, 'tests_failed.txt'))
    exit 1
  else
    exit 0
  end
end
