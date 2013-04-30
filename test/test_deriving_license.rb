require 'test/unit'
require 'deriving_license'

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
  
  def test_run_takes_one_arg
    assert_nothing_raised do
      DerivingLicense.run("Gemfile")
    end
  end

end