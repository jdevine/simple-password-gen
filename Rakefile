require 'bundler'
require 'rake/rdoctask'
Bundler::GemHelper.install_tasks

Rake::RDocTask.new(:docs) do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include('README.rdoc', 'LICENSE', 'lib/**/*.rb')
end
