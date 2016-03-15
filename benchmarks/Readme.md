### Benchmark Tests

Using Apache's JMeter framework, which is a Java application designed to load test functional behavior and measure performance.

http://jmeter.apache.org/


## Installation

### Ubuntu and vagrant-development
`sudo apt-get install jmeter`
`sudo apt-get install openjdk-6-jdk` (if generating graphs)

To install the plugins (Standard and Extras), go to http://jmeter-plugins.org/wiki/PluginInstall

When downloading and extracting the packages ensure that you save the plugin's bin and lib contents in the same directory structure (e.g. within /usr/share/jmeter)

```
|-usr/share/jmeter
| |-bin
| | |-jmeter.bat
| | |-ApacheJMeter.jar
| | |-merge-results.properties
| | |-...
| |-lib
| | |-ext
| | | |-JMeterPlugin-Standard.jar
| | | |-JMeterPlugins-Extras.jar
| | | |-CMDRunner.jar
| | | |-...
| | |-...
| |-...
|-...

```
More on JMeter Plugins here http://jmeter-plugins.org/wiki/PluginInstall/

### OSX

`brew install jmeter --with-plugins`

To open the GUI locally
`open /usr/local/bin/jmeter`


### Ruby DSL to Generate Test Plans

JMeter load tests are XML files. The ruby-jmeter DSL facilitates test plan creation
using ruby.

https://github.com/flood-io/ruby-jmeter

Add it to your Gemfile and `bundle install` or simply require rubygems and ruby-jmeter in an rb file.


### Running the Test Plan

`ruby path/to/testplan.rb`

Also, there is a rake task to generate test plan from a ruby-jmeter rb file and then runs the test.

`bundle exec rake benchmark:run_testplan['path/to/testplan.rb']`

or 

#### On development/vagrant

http://manpages.ubuntu.com/manpages/vivid/man1/jmeter.1.html

/usr/bin/jmeter  -t ./benchmarks/296_cache/testplan.jmx -j ./log/jmeter.log -l ./benchmarks/296_cache/results-staging.jtl -q ./benchmarks/jmeter/user.properties --nongui


### Reports


To generate graphics locally you can use the GUI and load the results to generate graphs, such as the composite graph. Also you can do it via the CMDRunner using the following rake task.

`bundle exec rake benchmark:generate_reports['PluginType','path/to/results.jtl','path/to/output/folder']`

bundle exec rake benchmark:generate_reports['LatenciesOverTime', './benchmarks/296_cache/results-staging.jtl', './benchmarks/296_cache']

will run

```
java -Djava.awt.headless=true -jar /usr/local/Cellar/jmeter/2.13/libexec/lib/ext/CMDRunner.jar --tool Reporter  --input-jtl ./benchmarks/296_cache/results-staging.jtl  --plugin-type LatenciesOverTime --generate-png ./benchmarks/296_cache/LatenciesOverTime.png --width 800 --height 600 --generate-csv ./benchmarks/296_cache/LatenciesOverTime.csv
```

`java -Djava.awt.headless=true -jar /usr/share/jmeter/lib/ext/CMDRunner.jar --tool Reporter  --input-jtl ./benchmarks/296_cache/results-staging.jtl  --plugin-type LatenciesOverTime --generate-png ./benchmarks/296_cache/LatenciesOverTime.png --width 800 --height 600 --generate-csv ./benchmarks/296_cache/LatenciesOverTime.csv`

## Example

See benchmark/296_cache/testplan.rb

bundle exec rake benchmark:run_testplan['./benchmarks/296_cache/testplan.rb']
bundle exec rake benchmark:generate_reports['LatenciesOverTime','./benchmarks/296_cache/results-staging.jtl','./benchmarks/296_cache']


