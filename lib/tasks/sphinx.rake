require 'fileutils'

namespace :sphinx do
  
  task :document_xml => :environment do
    puts DC::Import::SphinxXMLPipe.new.xml
  end
  
  task :start do
    unless sphinx_running?
      FileUtils.mkdir_p 'db/sphinx'
      Dir['db/sphinx/*.spl'].each {|file| File.delete(file) }
      sh 'searchd --pidfile --config config/sphinx.conf'
    end
  end
  
  task :stop do
    sh 'searchd --stop --config config/sphinx.conf' if sphinx_running?
  end
  
  task :restart => [:stop, :start]
  
  task :index do
    FileUtils.mkdir_p 'db/sphinx'
    rotate = sphinx_running? ? '--rotate' : ''
    sh "indexer --config config/sphinx.conf --all #{rotate}"
  end
  
  task :rebuild => [:stop, :index, :start]
  
end

def sphinx_pid
  pid_path = 'tmp/pids/searchd.pid'
  @sphinx_pid ||= File.exists?(pid_path) ? File.read(pid_path)[/\d+/].to_i : nil
end

def sphinx_running?
  !!sphinx_pid && !!Process.kill(0, sphinx_pid) rescue false
end