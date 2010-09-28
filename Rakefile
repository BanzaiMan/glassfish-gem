# 
#

require 'rubygems'
require 'spec/rake/spectask'

JAVA_LIBDIR = File.join(File.dirname(__FILE__), 'target', 'stage', 'lib', 'java')
JAVA_SPEC_FILES = Dir.glob('spec/java/**/*_spec.rb')

task :default => [:mvn, :spec]

desc "Run 'mvn install'"
task :mvn do
  system "mvn install"
end

spec_ns = namespace 'spec' do
  desc "Run specs on Java classes"
  Spec::Rake::SpecTask.new(:java) do |t|
    t.libs << JAVA_LIBDIR
    t.libs << File.join(File.dirname(__FILE__), 'lib')

    t.spec_files = JAVA_SPEC_FILES
  end
end

desc "Run specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.libs << JAVA_LIBDIR
  t.libs << File.join(File.dirname(__FILE__), 'lib')

  t.spec_files = Dir.glob('spec/**/*_spec.rb') - JAVA_SPEC_FILES - ['spec/asadmin_spec.rb']
end

task :spec => [:mvn, spec_ns[:java]]
