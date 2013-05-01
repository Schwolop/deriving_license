deriving_license
================

Finds the license agreements for all gems in your Gemfile. This is achieved by running through a collection of strategies for each dependency until one succeeds in determining the license in use.

Strategies:
* from\_gem\_specification
* from\_license\_file
* from\_scraping\_homepage
* from\_parsing\_readme (not yet implemented)

Example output:

    $ deriving_license ~/Code/rails_sample_app/Gemfile
	Determining license for rails:
		Trying from_gem_specification strategy...FAILED
		Trying from_scraping_homepage strategy...SUCCESS
	Determining license for adt:
		Trying from_gem_specification strategy...FAILED
		Trying from_scraping_homepage strategy...FAILED
		Trying from_license_file strategy...FAILED
	Determining license for app_constants:
		Trying from_gem_specification strategy...FAILED
		Trying from_scraping_homepage strategy...SUCCESS
		
	...
    
	Detected 4 known licenses:
	MIT: Expat License (14 instances)[http://directory.fsf.org/wiki/License:Expat]
	Ruby: Ruby License (6 instances)[http://www.ruby-lang.org/en/about/license.txt]
	BSD: FreeBSD Copyright (2 instances)[http://www.freebsd.org/copyright/freebsd-license.html]
	GPL: GNU General Public License (2 instances)[http://en.wikipedia.org/wiki/GNU_General_Public_License]