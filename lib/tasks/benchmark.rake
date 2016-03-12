namespace :benchmark do

  desc "Run jmeter test plan and output results"
  task :run_testplan, [:filename] => [:environment] do |t, args|
    raise "You need to install jmeter, see http://jmeter.apache.org/" if jmeter_path.blank?
    raise "Specify the full path to ruby-jmeter rb file" if args[:filename].blank?
    system "ruby #{args[:filename]}"
  end
  
  desc "Run jmeter plugins to generate graphs and output csv"
  task :generate_reports, [:plugin, :input_file, :output_path] => [:environment] do |t, args|
    raise "You need to install jmeter, see http://jmeter.apache.org/" if jmeter_path.blank?
    raise "Specify which plugin" if args[:plugin].blank?
    raise "Specify the input path to ruby-jmeter jtl file" if args[:input_file].blank?
    raise "Specify the output folder where graphs and/or reports will be saved" if args[:output_path].blank?

    width = args[:width] || 800
    height = args[:height] || 600

    system "java -Djava.awt.headless=true -jar #{jmeter_path}/lib/ext/CMDRunner.jar \
      --tool Reporter  --input-jtl #{args[:input_file]}  \
      --plugin-type #{args[:plugin]} \
      --generate-csv #{args[:output_path]}/#{args[:plugin]}.csv \
      --generate-png #{args[:output_path]}/#{args[:plugin]}.png \
      --width #{width} --height #{height}"
  end
  
  def jmeter_path
    jmeter_executable = `which jmeter`
    jmeter = jmeter_executable.strip == '/usr/local/bin/jmeter' ? '/usr/local/Cellar/jmeter/2.13/libexec' : '/usr/share/jmeter'
  end
end



#git commit benchmarks/Readme.md benchmarks/jmeter/user.properties -m "296 adds more jmeter plugin configs, updates readme, tweaks test plan to output more interesting results"
