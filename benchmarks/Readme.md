### Benchmark Tests

Using Apache's JMeter framework, which is a Java application designed to load test functional behavior and measure performance.

http://jmeter.apache.org/


## Installation

### ubuntu
`sudo apt-get install jmeter`
`sudo apt-get install openjdk-6-jdk` (if generating graphs)

### OSX

`brew install jmeter --with-plugins`

To open the GUI
`open /usr/local/bin/jmeter`


### Ruby DSL to Generate Test Plans

JMeter load tests are XML files. The ruby-jmeter DSL facilitates test plan creation
using ruby.

https://github.com/flood-io/ruby-jmeter

Add to it to your Gemfile and then `bundle install` or simply require rubygems and ruby-jmeter in rb file.

### Running the Test Plan

`ruby path/to/testplan.rb`

Also, there is a rake task to generate test plan from a ruby-jmeter rb file and then runs the test.

`bundle exec rake benchmark:run_testplan['path/to/testplan.rb']`


### Reports

See csv file specified on the test plan rb file. 

To generate graphics locally, open the GUI and load the results to generate graphs, such as the composite graph.

@TODO integrate jmeter plugins with CMD line tool to autogenerate the graphics after the results tree is populated.

## Example

See benchmark/296_cache/testplan.rb


