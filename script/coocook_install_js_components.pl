#!/usr/bin/env perl

# ABSTRACT: script for building the JavaScript components for the coocook frontend

use v5.28;
use utf8;
use warnings;
use strict;

use Term::ANSIColor;
use Cwd qw/abs_path getcwd/;
use File::Copy::Recursive qw/rcopy/;
use File::Path qw/rmtree make_path/;
use File::Fetch;

say colored('START INSTALLING COOCOOK JS COMPONENTS...', 'yellow');

say colored('CHECK IF AT TOP-LEVEL OF COOCOOK REPOSITORY...', 'yellow');
my $dir = abs_path(getcwd());
if (not ($dir =~ /^.*\/coocook$/)) {
    error('This script can only be executed in the top-level coocook repository');
}
say colored('CURRENT DIRECTORY IS TOP-LEVEL OF COOCOOK REPOSITORY', 'green');

say colored('DOWNLOAD FILES...', 'yellow');
make_path 'tmp/web_js_components';
my $index_js_ff = File::Fetch->new(uri => 'https://gitlab.com/coocook/web-js-components/-/raw/v0.0.4/dist/index.js');
my $index_css_ff = File::Fetch->new(uri => 'https://gitlab.com/coocook/web-js-components/-/raw/v0.0.4/dist/index.css');

$index_js_ff->fetch(to => 'tmp/web_js_components') or error($index_js_ff->error);
$index_css_ff->fetch(to => 'tmp/web_js_components') or error($index_css_ff->error);

if (not (-e 'tmp/web_js_components/index.js') || not (-e 'tmp/web_js_components/index.css')) {
    error('Download failed.');
}

say colored('DOWNLOAD FILES DONE.', 'green');


say colored('DELETE OLD JS COMPONENTS...', 'yellow');
rmtree('root/static/lib/web_js_components') or error("Failed removing 'root/static/lib/web_js_components'");
say colored('DELETE DONE.', 'green');

say colored('COPY NEW JS COMPONENTS...', 'yellow');
rcopy('tmp/web_js_components', 'root/static/lib/web_js_components') or error("Failed at copying the new files");
say colored('COPY DONE.', 'green');

rmtree('tmp');
say colored('INSTALLING COOCOOK JS COMPONENTS DONE.', 'green');

sub error {
    my $msg = shift;
    say '';
    say colored($msg, 'red');
    exit 1;
}
