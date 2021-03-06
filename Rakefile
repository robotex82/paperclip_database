require 'bundler/gem_tasks'
require 'appraisal'
require 'rake/testtask'
require 'cucumber/rake/task'

desc 'Default: clean, appraisal:install, all.'
task :default => [:clean, :all]

desc 'Test the paperclip_database plugin under all supported Rails versions.'
task :all do |t|
  if ENV['BUNDLE_GEMFILE']
    exec('rake test cucumber')
  else
    Rake::Task["appraisal:install"].execute
    exec('rake appraisal test cucumber')
  end
end

desc 'Test the paperclip_database plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'profile'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Run integration test'
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = %w{--format progress}
end

desc 'Start an IRB session with all necessary files required.'
task :shell do |t|
  chdir File.dirname(__FILE__)
  exec 'irb -I lib/ -I lib/paperclip_database -r rubygems -r active_record -r paperclip -r tempfile -r init'
end

desc 'Clean up files.'
task :clean do |t|
  FileUtils.rm_rf "doc"
  FileUtils.rm_rf "tmp"
  FileUtils.rm_rf "pkg"
  FileUtils.rm_rf "public"
  FileUtils.rm "test/debug.log" rescue nil
  FileUtils.rm "test/paperclip_database.db" rescue nil
  Dir.glob("paperclip_database-*.gem").each{|f| FileUtils.rm f }
end
