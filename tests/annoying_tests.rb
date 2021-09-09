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

  def test_change_wallet_password
    assert(KWalletd5.change_wallet_password(WALLET_NAME, APP_NAME))
  end

  def test_close
    @wc.close!
    assert(@wc.is_open == false)
  end

  def test_delete_wallet
     KWalletd5.delete_wallet(WALLET_NAME)
     assert(KWalletd5.does_wallet_exist(WALLET_NAME) == false)
  end

end
