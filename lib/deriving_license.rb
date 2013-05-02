require "gemnasium/parser"
require "bundler"
require "safe_yaml"
require "curb"
require "find"

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
    "Ruby" => {name:"Ruby License",link:"http://www.ruby-lang.org/en/about/license.txt",tags:[:gpl_compatible, :has_restrictions]},
    "Apache" => {name:"Apache License",link:"http://www.apache.org/licenses/LICENSE-2.0",tags:[:has_restrictions]},
  }

  @@license_aliases = {
    # hash of names to keys of the license in the master list.
    "FreeBSD" => "BSD",
    "Expat" => "MIT",
    "beer" => "beerware",
    "ruby" => "Ruby",
    "Apache License" => "Apache",
  }
  
  # String array of strategies to detect licenses. Write new class functions 
  # (that take a string of the dependency's name) then add their names here in 
  # order of fastest to slowest.
  @@strategies = [
    "from_gem_specification",
    "from_scraping_homepage",
    "from_license_file",
    "from_parsing_readme",
  ]
  
  @@specs_cache = {} # Cache of gem specifications previously fetched.

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
    
    if /(gemspec)+/.match(path.downcase)
      content = Gemnasium::Parser::Gemspec.new(content)
    else
      content = Gemnasium::Parser::Gemfile.new(content)
    end
    detected_licenses = Hash.new(0)
    detected_licenses["custom"]=[]
    
    # For each dependency specified...
    content.dependencies.each do |d|
      print "Determining license for #{d.name}:\n"
      # Try each license finding strategy...
      @@strategies.each do |s|
        print "\tTrying #{s} strategy..."
        @licenses = eval("#{s}(\"#{d.name}\")")
        unless @licenses.empty? # and break out of the search if successful
          if @licenses.count == 1 and @licenses[0] == "custom"
            print "CUSTOM\n"
          else
            print "SUCCESS\n"
          end
          break
        end
        print "FAILED\n"
      end
      @licenses.each do |l| # add each detected license to the results
        unless l == "custom"
          detected_licenses[l]+=1
        else
          detected_licenses["custom"] << "#{d.name}" # the 'custom' key is 
            # special and holds an array of the deps with custom licenses.
        end
      end
    end
    detected_licenses
  end
  
  def self.describe(licenses)
    # Print link to description of each license type, then attempt to determine 
    # whether any notable restrictions apply (e.g. you can't sell this project, 
    # you must include a copy of the GPL, etc)
    unrecognized = []
    output = []
    licenses.each do |l|
      unless l.first == "custom"
        instances = "(#{l.last} instance#{l.last == 1 ? "" : "s"})"
        key = @@license_aliases[l.first]
        key ||= l.first
        if @@license_details[key]
          output << "#{key}: #{@@license_details[key][:name]} #{instances}[#{@@license_details[key][:link]}]"
        else
          unrecognized << key
        end
      end
    end
    unless output.empty?
      puts "Detected #{output.count} known license#{output.count==1 ? "" : "s"}:"
      output.each{|o| puts o}
    end
    unless unrecognized.empty?
      puts "There #{unrecognized.count==1 ? "is" : "are"} also #{unrecognized.count} unrecognized license#{unrecognized.count==1 ? "" : "s"}: #{unrecognized.join(', ')}"
    end
    unless licenses["custom"].empty?
      puts "The following dependencies have custom licenses: #{licenses["custom"].join(', ')}"
    end
  end
  
  def self.get_gem_spec(dep)
    # Check spec cache first.
    @spec = @@specs_cache[dep]
    return @spec if @spec
    # See if the gem is installed locally, and if not add -r to call
    Bundler.with_clean_env do # This gets out of the bundler context.
      remote = /#{dep}/.match( `gem list #{dep}` ) ? "" : "-r "      
      yaml = `gem specification #{remote}#{dep} --yaml`
      @spec = YAML.load(yaml, :safe => true)
    end
    @@specs_cache[dep] = @spec # Cache it.
    @spec
  end
  
  def self.yield_gem_source_directory(dep)
    # Yields a path to a temporary directory containing the gem source, then 
    # cleans up after itself. Supply a block taking the gem_dir_path and 
    # interrogate the directory as required.
    Bundler.with_clean_env do # This gets out of the bundler context.
      @fetch_output = `gem fetch #{dep}`
      @unpack_output = `gem unpack #{dep} --target=./deriving_license_tmp`
    end
    unpack_dir = /'([\/a-zA-Z0-9._\-]*)'/.match(@unpack_output)[1]
    gem_filename = /Downloaded\ ([\/a-zA-Z0-9._\-]*)$/.match(@fetch_output)[1]
    gem_filename += ".gem"
    
    yield unpack_dir, gem_filename if block_given?
    
    `rm -rf ./deriving_license_tmp` # Clean up tmp dir. Don't fuck this up.
    `rm #{gem_filename}` # Remove fetched gem.
  end
  
  ##############
  # STRATEGIES #
  ##############
  def self.from_gem_specification(dep)
    spec = get_gem_spec(dep)
    spec["licenses"]
  end
  
  def self.from_license_file(dep)
    licenses = []

    yield_gem_source_directory(dep) do |gem_source_directory|

      license_file_paths = []
      Find.find(gem_source_directory) do |path|
        license_file_paths << path if path =~ /(license|LICENSE)$/
      end
      break unless license_file_paths
    
      # Found filename with the word "license", so now look for known license 
      # names in the rest of this filename.
      license_file_paths.each do |p|
        (@@license_details.keys + @@license_aliases.keys).each do |n|
          if /#{n}/.match(p)
            licenses << n
            break
          end
        end
      end
    
      if licenses.empty?
        # Failing that, open each file and check the content in a similar manner.
        license_file_paths.each do |p|
          if File.exist?(p)
            File.open(p).each_line do |l|
              if /license/.match(l)
                # Found the word "license", so now look for known license names.
                (@@license_details.keys + @@license_aliases.keys).each do |n|
                  if /#{n}/.match(l)
                    licenses << n
                    break
                  end
                end
              end
            end
          end
        end
      end
      
      # Finally, if we couldn't find a known license, but a license file 
      # exists, report it as custom.
      licenses << "custom"
      
    end # end of call to yield_gem_source_directory
    
    return licenses

  end
  
  def self.from_scraping_homepage(dep)
    spec = get_gem_spec(dep)
    licenses = []
    unless spec["homepage"] and !spec["homepage"].empty?
      return []
    end
    begin
      content = Curl::Easy.perform(spec["homepage"]){|easy| easy.follow_location = true; easy.max_redirects=nil}.body_str
    rescue
      return []
    end
    content.split('\n').each do |l|
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
    return licenses # If we didn't return early, there's no match.
  end
  
  def self.from_parsing_readme(dep)
    licenses = []

    yield_gem_source_directory(dep) do |gem_source_directory|

      readme_file_paths = []
      Find.find(gem_source_directory) do |path|
        readme_file_paths << path if path =~ /(read\.me|readme|README)$/
      end
      break unless readme_file_paths
    
      # Open each readme file and check the content.
      readme_file_paths.each do |p|
        if File.exist?(p)
          File.open(p).each_line do |l|
            if /license/.match(l)
              # Found the word "license", so now look for known license names.
              (@@license_details.keys + @@license_aliases.keys).each do |n|
                if /#{n}/.match(l)
                  licenses << n
                  break
                end
              end
            end
          end
        end
      end
    
    end # end of call to yield_gem_source_directory
    return licenses
  end
  
end # end of DerivingLicense class