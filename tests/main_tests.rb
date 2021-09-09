#!/snap/bin/ruby
#
# Author: Eric Power

# Imports
require 'test/unit'
require '../src/kwalletd5-ruby-interface'
include KWalletd5

# Globals
APP_NAME = "kwd5-rb-tests"
WALLET_NAME = "kwd5-rb-tests-wallet"

class KWalletd5Tests < Test::Unit::TestCase

  def setup
    @wc = KWalletd5::KWalletConnection.new(WALLET_NAME, APP_NAME)
  end

  def teardown
  end

  Test::Unit.at_start do
    KWalletd5.delete_wallet KWalletd5
  end

  Test::Unit.at_exit do
    KWalletd5.delete_wallet KWalletd5
  end

  # KWalletConnection Tests

  def test_is_open
    assert(@wc.is_open)
  end

  def test_replace_key
    @wc.create_folder("main_tests")
    @wc.write_entry("main_tests", "rk1", "value_11")
    @wc.replace_key("main_tests", "rk1", "__replaced_key_1")
    assert(@wc.lookup_entry("main_tests", "__replaced_key_1") == "value_11")
  end

  def test_list_keys
    @wc.write_entry("main_tests", "lk-1", "value_30")
    keys = @wc.list_keys("main_tests")
    assert(keys.include?("lk-1"), "Returned List: #{keys}")
  end

  def test_does_key_exist
    @wc.write_entry("main_tests", "dke-1", "v-dke-1")
    assert(@wc.does_key_exist("main_tests", "dke-1"))
  end

  def test_write_entry
    @wc.write_entry("main_tests", "we-1", "v-we-1")
    assert(@wc.does_key_exist("main_tests", "we-1"))
  end

  def test_lookup_entry
    @wc.write_entry("main_tests", "le-1", "v-le-1")
    assert(@wc.lookup_entry("main_tests", "le-1") == "v-le-1")
  end

  def test_delete_entry
    @wc.write_entry("main_tests", "de-1", "v-de-1")
    @wc.delete_entry("main_tests", "de-1")
    assert(@wc.lookup_entry("main_tests", "de-1") == "")
  end

  def test_write_password
    @wc.write_password("main_tests", "wp-1", "v-wp-1")
    assert(@wc.does_key_exist("main_tests", "wp-1"))
  end

  def test_lookup_password
    @wc.write_password("main_tests", "lp-1", "v-lp-1")
    assert(@wc.lookup_password("main_tests", "lp-1") == "v-lp-1")
  end

  def test_write_map
    @wc.write_map("main_tests", "wm-1", "v-wm-1")
    assert(@wc.does_key_exist("main_tests", "wm-1"))
  end

  def test_lookup_map
    @wc.write_map("main_tests", "lm-1", "v-lm-1")
    assert(@wc.lookup_map("main_tests", "lm-1") == "v-lm-1")
  end

  def test_create_folder
    @wc.delete_folder("main_tests_cf_1")
    @wc.create_folder("main_tests_cf_1")
    assert(@wc.does_folder_exist("main_tests_cf_1"))
  end

  def test_delete_folder
    @wc.create_folder("main_tests_df_1")
    @wc.delete_folder("main_tests_df_1")
    assert(@wc.does_folder_exist("main_tests_df_1") == false)
  end

  def test_list_folders
    @wc.create_folder("main_tests_lf_1")
    assert(@wc.does_folder_exist("main_tests_lf_1"))
  end

  def test_does_folder_exist
    @wc.create_folder("main_tests_dfe_1")
    assert(@wc.does_folder_exist("main_tests_dfe_1"))
  end

  # Direct Function Tests

  def test_list_wallets
    assert(KWalletd5.list_wallets)
  end

  def test_list_users
    assert(KWalletd5.list_users(WALLET_NAME))
  end

  def test_is_wallet_open
    assert(KWalletd5.is_wallet_open(WALLET_NAME))
  end

  def test_does_wallet_exist
    assert(KWalletd5.does_wallet_exist(WALLET_NAME))
  end

end
