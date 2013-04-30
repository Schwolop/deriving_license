require "gemnasium/parser"

class DerivingLicense
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
    
    licenses = Hash.new(0)
    gemfile.dependencies.each do |d|
      # See if it's installed locally, and if not add -r to call
      remote = /#{d.name}/.match( `gem list #{d.name}` ) ? "" : "-r "
      
      print "Determining license for #{d.name}#{remote.empty? ? "" : " (remote call required)"}..."; STDOUT.flush
      spec = eval `gem specification #{remote}#{d.name} --ruby`
      print "DONE\n"; STDOUT.flush
      spec.licenses.each{ |l| licenses[l]+=1 }
    end
    licenses
  end
end