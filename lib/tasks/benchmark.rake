namespace :benchmark do

  desc "Run jmeter test plan and output results"
  task :run_testplan, [:filename] => [:environment] do |t, args|
    raise "You need to install jmeter, see http://jmeter.apache.org/" if !system('which jmeter')
    raise "Specify the full path to ruby-jmeter rb file" if args[:filename].blank?
    system("ruby #{args[:filename]}")
  end
end
