#!/snap/bin/ruby
#
# Author: Eric Power
#
# Description:
#     A module that provides an interface for communicating with the KDE wallet
#     provided in Plasma 5.
#
#     The interface is split into two categories:
#         1. A KwalletConnection
#             initializing a KwalletConnection Object will ensure that the wallet
#             is open (KWallet will prompt the user if required), and make reading
#             and writing from that wallet easy.
#         2. Direct functions
#             These functions provide tools to interact with KDE Wallet outside
#             of a particular wallet. This includes things like checking which
#             wallets exist, creating new wallets, pinging the Kwallet daemon,
#             setting priorities, and more.
#
#     This module will raise StandardErrors if qdbus or kwalletd5 is not available
#     on the local machine.
#
#     All calls to this module will raise StandardErrors if the call to qdbus
#     fails. Check the associated error message for information on why the call
#     failed.
#
#     Released under the MIT License.
#     Full license at https://github.com/epwr/kwalletd5-ruby-interface/LICENSE

# Dependencies
require 'open3'

if `which kwalletd5 2>&1` == ""
  raise "Kwalletd5 Ruby Interface requires `kwalletd5` be installed on your system."
elsif `which qdbus 2>&1` == ""
  raise "Kwalletd5 Ruby Interface requires `qdbus` be installed on your system."
end


module KWalletd5

  # KWalletConnection
  #     Used to either open or create a wallet. The user will be prompted if KDE
  #     Wallet requires their authorization. The prompt will include app_name,
  #     so make sure that the user will recognize your app_name.
  class KWalletConnection

    def initialize(wallet_name, app_name, window_id: "0")
      # TODO: explain window_id here.
      @app_name  = app_name
      @wallet_id = message_kwd5("open", wallet_name, window_id, app_name)
      @wallet_name = wallet_name
    end

    def replace_key(folder, old_key, new_key)
      message_kwd5("renameEntry", @wallet_id, folder, old_key, new_key, @app_name)
    end

    def list_keys(folder)
      message_kwd5("entryList", @wallet_id, folder, @app_name).split("\n")
    end

    def does_key_exist(folder, key)
      message_kwd5("entryList", @wallet_id, folder, @app_name).split("\n").include?(key)
    end

    def write_entry(folder, key, value)
      message_kwd5("writeEntry", @wallet_id, folder, key, value, @app_name)
    end

    def lookup_entry(folder, key)
      message_kwd5("readEntry", @wallet_id, folder, key, @app_name)
    end

    def delete_entry(folder, key)
      message_kwd5("removeEntry", @wallet_id, folder, key, @app_name)
    end

    def write_password(folder, key, value)
      message_kwd5("writePassword", @wallet_id, folder, key, value, @app_name)
    end

    def lookup_password(folder, key)
      message_kwd5("readPassword", @wallet_id, folder, key, @app_name)
    end

    def write_map(folder, key, value)
      message_kwd5("writeMap", @wallet_id, folder, key, value, @app_name)
    end

    def lookup_map(folder, key)
      message_kwd5("readMap", @wallet_id, folder, key, @app_name)
    end

    def create_folder(folder)
      message_kwd5("createFolder", @wallet_id, folder, @app_name)
    end

    def delete_folder(folder)
      message_kwd5("removeFolder", @wallet_id, folder, @app_name)
    end

    def list_folders
      message_kwd5("folderList", @wallet_id, @app_name)
    end

    def does_folder_exist(folder)
      message_kwd5("hasFolder", @wallet_id, folder, @app_name) == "true"
    end

    def is_open
      msg = message_kwd5("isOpen", @wallet_name) == "true"
    end

    def close!
      message_kwd5("close", @wallet_id, true, @app_name)
    end
  end

  # Direct Functions

  def change_wallet_password(wallet_name, app_name, window_id: "0")
    # Kwalletd5 returns "-1" if the prompt opens properly. No way of telling if
    # the password was actually changed (at least not via qdbus).
    message_kwd5("changePassword", wallet_name, app_name, window_id) == "-1"
  end

  def list_wallets
    message_kwd5("wallets")
  end

  def list_users(wallet_name)
    message_kwd5("users", wallet_name)
  end

  def delete_wallet(wallet_name)
    message_kwd5("deleteWallet", wallet_name)
  end

  def is_wallet_open(wallet_name)
    message_kwd5("isOpen", wallet_name) == "true"
  end

  def does_wallet_exist(wallet_name)
    message_kwd5("wallets").split("\n").include?(wallet_name)
  end

  # Private helper functions

  private
  def message_kwd5(method, *args, path: "/modules/kwalletd5")
    # TODO: Test if capture3 handles escaping characters.
    # TODO: handle the case where a string contains "\;" already (escape both?)
    #         args.each{ |arg| arg.split(";").join("\;") }
    stdout, stderr, status = Open3.capture3("qdbus org.kde.kwalletd5 #{path} #{method} #{args.join(" ")}")
    unless stderr == ""
      raise stderr + " -- ran: qdbus org.kde.kwalletd5 #{path} #{method} #{args.join(" ")}"
    end
    unless status == 0
      raise "Method call returned error code: #{status}. stdout = '#{stdout}', stderr = '#{stderr}'" +
        " -- ran: qdbus org.kde.kwalletd5 #{path} #{method} #{args.join(" ")}"
    end
    stdout.strip()
  end

end
