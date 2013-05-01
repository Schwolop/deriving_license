require "gemnasium/parser"
require "bundler"
require "safe_yaml"
require "open-uri"

class DerivingLicense
  
  attr_reader :license_details, :license_aliases
  
  # TODO: Scrape http://www.gnu.org/licenses/license-list.html#SoftwareLicenses 
  # and auto-magically generate these details.
  @@license_details = {
    # key -> hash of (Name, Link, [Tags]), where tags is an array that may include [:gpl_compatible, :copyleft_compatible, :has_restrictions]
    "GPL" => {name:"GNU General Public License",link:"http://en.wikipedia.org/wiki/GNU_General_Public_License",tags:[:gpl_compatible, :copyleft_compatible, :has_restrictions]},
    "MIT" => {name:"Expat License",link:"http://directory.fsf.org/wiki/License:Expat",tags:[:gpl_compatible, :has_restrictions]},
    "BSD" => {name:"FreeBSD Copyright",link:"http://www.freebsd.org/copyright/freebsd-license.html",tags:[:gpl_compatible, :copyleft_compatible, :has_restrictions]},
    "beerware" => {name:"Beerware License",link:"http://en.wikipedia.org/wiki/Beerware#License",tags:[]},
    "Ruby" => {name:"Ruby License",link:"http://www.ruby-lang.org/en/about/license.txt",tags:[:gpl_compatible, :has_restrictions]}
  }

  @@license_aliases = {
    # hash of names to keys of the license in the master list.
    "FreeBSD" => "BSD",
    "Expat" => "MIT",
    "beer" => "beerware",
    "ruby" => "Ruby"
  }
  
  # String array of strategies to detect licenses. Write new class functions 
  # (that take a string of the dependency's name) then add their names here in 
  # order of fastest to slowest.
  @@strategies = [
    "from_gem_specification",
    "from_scraping_homepage"
  ]

  def self.run(path=nil)
    unless path
      raise ArgumentError.new("Path to Gemfile or Gemspec required")
    end
    
    unless /(gemfile|gemspec)+/.match(path.downcase)
      raise ArgumentError.new("Argument must be a path to Gemfile or Gemspec")
    end
    
    begin
      content = File.open(path, "r").read
    rescue
      raise "Invalid path to gemfile or gemspec."
    end
    
    gemfile = Gemnasium::Parser::Gemfile.new(content)
    
    detected_licenses = Hash.new(0)
    
    # For each dependency specified...
    gemfile.dependencies.each do |d|
      print "Determining license for #{d.name}:\n"
      # Try each license finding strategy...
      @@strategies.each do |s|
        print "\tTrying #{s} strategy..."
        @licenses = eval("#{s}(\"#{d.name}\")")
        unless @licenses.empty? # and break out of the search if successful
          print "SUCCESS\n"
          break
        end
        print "FAILED\n"
      end
      @licenses.each{ |l| detected_licenses[l]+=1 } # add each detected license to the results
    end
    detected_licenses
  end
  
  def self.describe(licenses)
    # Print link to description of each license type, then attempt to determine 
    # whether any notable restrictions apply (e.g. you can't sell this project, 
    # you must include a copy of the GPL, etc)
    unknowns = []
    output = []
    licenses.each do |l|
      instances = "(#{l.last} instance#{l.last == 1 ? "" : "s"})"
      key = @@license_aliases[l.first]
      key ||= l.first
      if @@license_details[key]
        output << "#{key}: #{@@license_details[key][:name]} #{instances}[#{@@license_details[key][:link]}]"
      else
        unknowns << key
      end
    end
    unless output.empty?
      puts "Detected #{output.count} known license#{output.count==1 ? "" : "s"}:"
      output.each{|o| puts o}
    end
    unless unknowns.empty?
      puts "There #{unknowns.count==1 ? "is" : "are"} also #{unknowns.count} unknown license#{unknowns.count==1 ? "" : "s"}: #{unknowns.join(', ')}"
    end
  end
  
  def self.get_gem_spec(dep)
    # See if the gem is installed locally, and if not add -r to call
    Bundler.with_clean_env do # This gets out of the bundler context.
      remote = /#{dep}/.match( `gem list #{dep}` ) ? "" : "-r "      
      yaml = `gem specification #{remote}#{dep} --yaml`
      @spec = YAML.load(yaml, :safe => true)
    end
    @spec
  end
  
  ##############
  # STRATEGIES #
  ##############
  def self.from_gem_specification(dep)
    spec = get_gem_spec(dep)
    spec["licenses"]
  end
  
  def self.from_license_file(dep)
    []
  end
  
  def self.from_scraping_homepage(dep)
    spec = get_gem_spec(dep)
    licenses = []
    unless spec["homepage"]
      []
    end
    content = open(spec["homepage"])
    content.each_line do |l|
      if /license/.match(l)
        # Found the word "license", so now look for known license names.
        (@@license_details.keys + @@license_aliases.keys).each do |n|
          if /#{n}/.match(l)
            licenses << n
            return licenses
          end
        end
      end
    end
    [] # If we didn't return early, there's no match.
  end
  
  def self.from_parsing_readme(dep)
    []
  end
end