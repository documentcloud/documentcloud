require 'rubygems'
require 'ruby-jmeter'

test do
  threads count: 5 do
    visit name: 'DocumentCloud Home', url: 'https://staging.documentcloud.org'
  end
  
  
  threads count: 50 do
    # 296 Reliably cache/expire:
    # JS/JSON endpoints
    visit name: 'JSON', url: 'https://staging.documentcloud.org/documents/282753-lefler-thesis.json'
    visit name: 'JSON with callback', url: 'https://staging.documentcloud.org/documents/282753-lefler-thesis.json?callback=foo'
    visit name: 'JS', url: 'https://staging.documentcloud.org/documents/282753-lefler-thesis.js'
    # Iframe embed show pages
    visit name: 'Iframe embed page', url: 'https://staging.documentcloud.org/documents/282753-lefler-thesis/pages/57.html'
    visit name: 'Iframe embed page embed params', url: 'https://staging.documentcloud.org/documents/282753-lefler-thesis/pages/57.html?embed=true'
    visit name: 'Iframe embed document', url: 'https://staging.documentcloud.org/documents/282753-lefler-thesis/annotations/42282.html'
    visit name: 'Iframe embed document with embed params', url: 'https://staging.documentcloud.org/documents/282753-lefler-thesis/annotations/42282.html?embed=true'
    # oEmbed endpoints
    visit name: 'oEmbed', url: 'https://staging.documentcloud.org/api/oembed.json?url=https%3A%2F%2Fstaging.documentcloud.org%2Fdocuments%2F282753-lefler-thesis%2Fannotations%2F42282.html'
    visit name: 'oEmbed with responsive params', 
    url: 'https://staging.documentcloud.org/api/oembed.json?url=https%3A%2F%2Fstaging.documentcloud.org%2Fdocuments%2F282753-lefler-thesis.html&responsive=true'
  end
  
  cache use_expires: true, clear_each_iteration: true
  
  view_results_tree
  generate_summary_results
  summary_report

  latencies_over_time 'Response Latencies Over Time'
  active_threads 'Active Threads'
  
  composite 'Composite Graph', [
    {
      graph: 'Response Latencies Over Time',
      metric: ['DocumentCloud Home', 'JSON', 'JS']
    },
    {
        graph: 'Active Threads',
        metric: 'Overall Active Threads'
    }
  ]

end.run(
  file: './benchmarks/296_cache/testplan.jmx',
  log: './log/jmeter.log',
  jtl: './benchmarks/296_cache/results-staging.jtl',
  properties: './benchmarks/jmeter/user.properties',
  path:  '/usr/bin/', gui: false) # ubuntu/vagrant'
  # path:  '/usr/local/bin/') # local MacOSX
