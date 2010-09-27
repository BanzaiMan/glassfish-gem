# 
#

require 'rubygems'
require 'spec/rake/spectask'

task :default => [:mvn, :spec]

desc "Run 'mvn install'"
task :mvn do
  system "mvn install"
end

desc "Run specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.libs << File.join(File.dirname(__FILE__), 'target', 'stage', 'lib', 'java')
  t.libs << File.join(File.dirname(__FILE__), 'lib')

#  t.spec_files = Dir.glob('spec/**/*_spec.rb')
  t.spec_files = ['spec/command_line_parser_spec.rb']
end
