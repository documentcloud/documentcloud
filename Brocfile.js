var funnel      = require('broccoli-funnel');
var mergeTrees  = require('broccoli-descriptive-merge-trees');
var compileSass = require('broccoli-sass');
var bower       = require('broccoli-bower');
var uglify      = require('broccoli-uglify-js');

var appRoot = 'public'; // Set up the base directory for all of our source files

// Collect all of our javascripts and map them into an output directory called "javascripts"
var app = funnel(appRoot, {
  srcDir: 'javascripts',
  destDir: 'javascripts'
});

// Collect all of our stylesheets and map them into an output directory called "stylesheets"
var css = funnel(appRoot, {
  srcDir: 'stylesheets',
  destDir: 'stylesheets',
  exclude: ["**/*.scss"]
});

// Compile master sass file into assets
var sassDependencies = ['public'];
var sass = compileSass(sassDependencies, 'stylesheets/v2/example.scss', 'stylesheets/v2/example.css');

// coalesce all the different assets into one directory.
module.exports = mergeTrees([app, css, sass]);
