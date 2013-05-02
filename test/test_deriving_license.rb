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

  def test_run_throws_with_multiple_args
    assert_raise ArgumentError do
      DerivingLicense.run("Gemfile1", "Gemfile2")
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
  
  def test_run_with_valid_arg
    assert_nothing_raised do
      DerivingLicense.run("Gemfile")
    end
    assert_equal( {"MIT"=>1}, DerivingLicense.run("Gemfile") )
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

end