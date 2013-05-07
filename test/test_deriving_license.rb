require 'simplecov'
SimpleCov.start

require 'test/unit'
require 'deriving_license'

# Monkey-patch stdout to test puts calls
require 'stringio'
module Kernel
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out
  ensure
    $stdout = STDOUT
  end
end

class DerivingLicenseTest < Test::Unit::TestCase
  def test_run_throws_with_no_args
    assert_raise ArgumentError do
      DerivingLicense.run()
    end
  end

  def test_run_throws_if_path_is_invalid
    assert_raise ArgumentError do
      DerivingLicense.run("Ceci n'est pas un dossier.")
    end
  end
  
  def test_run_throws_if_path_is_invalid_but_matches_gemfile_regex
    assert_raise RuntimeError do
      DerivingLicense.run("Ceci n'est pas un gemfile.")
    end
  end
  
  def test_run_with_empty_gemfile_returns_empty_hash
    assert_equal( true, DerivingLicense.run("./test/empty.gemfile").empty? )
  end
  
  def test_run_with_valid_gemfile_arg
    result = {}
    assert_nothing_raised do
      output = capture_stdout do
        result = DerivingLicense.run("Gemfile")
      end
    end
    assert_equal( true, result.has_key?("MIT") )
  end
  
  def test_run_with_valid_gemspec_arg
    result = {}
    assert_nothing_raised do
      output = capture_stdout do
        result = DerivingLicense.run("deriving_license.gemspec")
      end
    end
    assert_equal( true, result.has_key?("MIT") )
  end
  
  def test_run_with_non_existant_strategies
    assert_raise RuntimeError do
      output = capture_stdout do
        DerivingLicense.run("Gemfile", ["cheese_strategy"])
      end
    end
  end
  
  def test_describe_with_known_license
    output = capture_stdout do
      DerivingLicense.describe({"MIT" => 1})
    end
    assert_equal( false, /Detected/.match( output.string ).nil? )
  end
  
  def test_describe_with_unrecognized_license
    output = capture_stdout do
      DerivingLicense.describe({"Cheese" => 1})
    end
    # Shouldn't say "detected"
    assert_equal( true, /Detected/.match( output.string ).nil? )
    # Should say "unknown"
    assert_equal( false, /unrecognized/.match( output.string ).nil? )
  end
  
  def test_describe_with_custom_license
    output = capture_stdout do
      DerivingLicense.describe( {"custom" => ["fake-gem"]} )
    end
    assert_equal( false, /have custom license/i.match( output.string ).nil? )
  end
  
  def test_from_scraping_strategy
    result = {}
    output = capture_stdout do
      result = DerivingLicense.run("./test/requires_scraping.gemfile", ["from_scraping_homepage"])
    end
    assert_equal( false, result.empty? )
    assert_equal( false, /from_scraping_homepage strategy...SUCCESS/.match( output.string ).nil? ) # Should be SUCCESS
  end
  
  def test_from_scraping_strategy_with_invalid_homepage
    result = {}
    output = capture_stdout do
      result = DerivingLicense.run("./test/requires_scraping_but_invalid_homepage.gemfile", ["from_scraping_homepage"])
    end
    assert_equal( true, result.empty? )
    assert_equal( false, /from_scraping_homepage strategy...FAILED/.match( output.string ).nil? ) # Should be FAILED
  end

  def test_from_license_filename
    result = {}
    output = capture_stdout do
      result = DerivingLicense.run("./test/requires_license_filename.gemfile", ["from_license_file"])
    end
    assert_equal( false, result.empty? )
    assert_equal( true, /from_license_file strategy...FAILED/.match( output.string ).nil? ) # Shouldn't be FAILED
  end
  
  def test_from_license_file_parsing
    result = {}
    output = capture_stdout do
      result = DerivingLicense.run("./test/requires_license_file_parsing.gemfile", ["from_license_file"])
    end
    assert_equal( false, result.empty? )
    assert_equal( true, /from_license_file strategy...FAILED/.match( output.string ).nil? ) # Shouldn't be FAILED
  end
  
  def test_from_license_file_parsing_but_is_custom
    result = {}
    output = capture_stdout do
      result = DerivingLicense.run("./test/requires_license_file_parsing_but_is_custom.gemfile", ["from_license_file"])
    end
    assert_equal( false, result.empty? )
    assert_equal( false, /from_license_file strategy...CUSTOM/.match( output.string ).nil? ) # Should be CUSTOM
  end
  
  def test_from_readme_file_parsing
    result = {}
    output = capture_stdout do
      result = DerivingLicense.run("./test/requires_readme_file_parsing.gemfile", ["from_parsing_readme"])
    end
    assert_equal( false, result.empty? )
    assert_equal( false, /from_parsing_readme strategy...SUCCESS/.match( output.string ).nil? )
  end
  
  def test_gemfile_with_call_to_gemspec
    gemfileResult = {}
    gemspecResult = {}
    output = capture_stdout do
      gemfileResult = DerivingLicense.run("Gemfile")
      gemspecResult = DerivingLicense.run("deriving_license.gemspec")
    end
    gemspecResult.each do |k,v|
      # Each license found in the gemspec should be found in the gemfile too 
      # (because the gemfile includes the gemspec, so it's a superset.)
      assert_equal( true, gemfileResult.has_key?(k) )
    end
    assert_equal( true, gemfileResult.count >= gemspecResult.count )
  end
  
end