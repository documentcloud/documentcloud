var funnel      = require('broccoli-funnel');
var mergeTrees  = require('broccoli-descriptive-merge-trees');
var compileSass = require('broccoli-sass');
var bower       = require('broccoli-bower');
var uglify      = require('broccoli-uglify-js');

var appRoot = 'public';
var app = funnel(appRoot, {
  srcDir: 'javascripts',
  destDir: 'javascripts'
});

var styles = funnel(appRoot, {
  srcDir: 'stylesheets',
  destDir: 'stylesheets'
});

module.exports = mergeTrees([app, styles]);
