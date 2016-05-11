var funnel      = require('broccoli-funnel');
var mergeTrees  = require('broccoli-descriptive-merge-trees');
var compileSass = require('broccoli-sass');
var bower       = require('broccoli-bower');
var uglify      = require('broccoli-uglify-js');

var path = require('path');

var appRoot = path.join(__dirname, 'public'); // Set up the base directory for all of our source files
console.log("Building from "+appRoot);

// Collect all of our javascripts and map them into an output directory called "javascripts"
var app = funnel(appRoot, {
  srcDir: 'javascripts',
  destDir: 'javascripts',
  include: ["**/*.js"]
});

// Collect all of our stylesheets and map them into an output directory called "stylesheets"
var css = funnel(appRoot, {
  srcDir: 'stylesheets',
  destDir: 'stylesheets',
  include: ["**/*.css"]
});

// Compile master sass file into assets

// NB: SCSS @import statements first search relative to the parent (importing) 
// file, then looks relative to these roots, in order. We include the 
// `javascripts/vendor` directory here because some Bower-installed packages 
// (VisualSearch, Bootstrap) contain CSS files we want.
var sassDependencies = ['public'];

// NB: No matter how many paths `sassDependencies` contains, `compileSass()` 
// will only search the first one for the input/output files (second/third args)
var sass = compileSass(sassDependencies, 'stylesheets/bootstrapped/primary.scss', 'styles/primary.css');


// coalesce all the different assets into one directory.
module.exports = mergeTrees([app, sass]);
