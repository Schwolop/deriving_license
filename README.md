deriving_license
================

Finds the license agreements for all gems in your Gemfile. This is achieved by running through a collection of strategies for each dependency until one succeeds in determining the license in use.

Strategies:
* from\_gem\_specification
* from\_license\_file (not yet implemented)
* from\_scraping\_homepage
* from\_parsing\_readme (not yet implemented)

Example output:

    $ deriving_license ../bc/A-A/Gemfile
    Determining license for rails:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...SUCCESS
    Determining license for adt:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...FAILED
    Determining license for app_constants:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...SUCCESS
    Determining license for bcrypt-ruby:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...FAILED
    Determining license for bootstrap-sass:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...FAILED
    Determining license for jquery-rails:
    	Trying from_gem_specification strategy...SUCCESS
    Determining license for json:
    	Trying from_gem_specification strategy...SUCCESS
    Determining license for nokogiri:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...SUCCESS
    Determining license for pg:
    	Trying from_gem_specification strategy...SUCCESS
    Determining license for quiet_assets:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...SUCCESS
    Determining license for rack-protection:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...FAILED
    Determining license for symmetric-encryption:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...SUCCESS
    Determining license for newrelic_rpm:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...SUCCESS
    Determining license for uglifier:
    	Trying from_gem_specification strategy...SUCCESS
    Determining license for sass-rails:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...FAILED
    Determining license for coffee-rails:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...FAILED
    Determining license for rspec-rails:
    	Trying from_gem_specification strategy...SUCCESS
    Determining license for capybara:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...SUCCESS
    Determining license for factory_girl_rails:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...SUCCESS
    Determining license for faker:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...SUCCESS
    Determining license for better_errors:
    	Trying from_gem_specification strategy...SUCCESS
    Determining license for binding_of_caller:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...SUCCESS
    Determining license for debugger:
    	Trying from_gem_specification strategy...SUCCESS
    Determining license for simplecov:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...SUCCESS
    Determining license for ci_reporter:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...SUCCESS
    Determining license for sqlite3:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...FAILED
    Determining license for mysql2:
    	Trying from_gem_specification strategy...FAILED
    	Trying from_scraping_homepage strategy...SUCCESS
    
    Detected 4 known licenses:
    MIT: Expat License (12 instances)[http://directory.fsf.org/wiki/License:Expat]
    Ruby: Ruby License (6 instances)[http://www.ruby-lang.org/en/about/license.txt]
    BSD: FreeBSD Copyright (2 instances)[http://www.freebsd.org/copyright/freebsd-license.html]
    GPL: GNU General Public License (2 instances)[http://en.wikipedia.org/wiki/GNU_General_Public_License]