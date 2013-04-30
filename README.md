deriving_license
================

Finds the license agreements for all gems in your Gemfile

Example output:

    $ deriving_license ~/Code/rails_sample_app/Gemfile
    Determining license for rails...UNKNOWN
    Determining license for adt...UNKNOWN
    Determining license for app_constants (remote call required)...UNKNOWN
    Determining license for bcrypt-ruby...UNKNOWN
    Determining license for bootstrap-sass...UNKNOWN
    Determining license for jquery-rails...SUCCESS
    Determining license for json...SUCCESS
    Determining license for nokogiri...UNKNOWN
    Determining license for pg...SUCCESS
    Determining license for quiet_assets...UNKNOWN
    Determining license for rack-protection...UNKNOWN
    Determining license for symmetric-encryption (remote call required)...UNKNOWN
    Determining license for newrelic_rpm...UNKNOWN
    Determining license for uglifier...SUCCESS
    Determining license for sass-rails...UNKNOWN
    Determining license for coffee-rails...UNKNOWN
    Determining license for rspec-rails...SUCCESS
    Determining license for capybara...UNKNOWN
    Determining license for factory_girl_rails...UNKNOWN
    Determining license for faker...UNKNOWN
    Determining license for better_errors...SUCCESS
    Determining license for binding_of_caller...UNKNOWN
    Determining license for debugger...SUCCESS
    Determining license for simplecov...UNKNOWN
    Determining license for ci_reporter...UNKNOWN
    Determining license for sqlite3...UNKNOWN
    Determining license for mysql2...UNKNOWN
    
    Detected 3 known licenses:
    MIT: Expat License (4 instances)[http://directory.fsf.org/wiki/License:Expat]
    BSD: FreeBSD Copyright (2 instances)[http://www.freebsd.org/copyright/freebsd-license.html]
    GPL: GNU General Public License (1 instance)[http://en.wikipedia.org/wiki/GNU_General_Public_License]
    There is also 1 unknown license: Ruby