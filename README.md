# kwalletd5-ruby-interface

A Ruby module that provides access to the KDE Wallet (for Plasma 5) through the
Qt DBus interface. Previous versions of KDE Wallet (eg. for Plasma 4) are not
supported by this module.

This README is broken into the following sections:

1. The kwalletd5-ruby-interface

2. Understanding the KDE Wallet (KWallet)

3. Understanding Qt DBUS (qdbus)

The first section is probably what you're interested in. However, to understand
how to use the module, you'll want a decent idea of what KDE wallet provides.
That's part 2. If you want to understand the module enough to edit it - you need
to understand Qt's DBus. Qt's documentation is great, so I've just
linked to that.

### Installation

This package is published as a ruby gem. To install it, simply run:

    gem install kwalletd5-wrapper

## 1. The kwalletd5-ruby-interface

This module (KWalletd5) provides an interface that is split into two main parts:

1.  A class called KWalletConnection that allows connecting to, and editing, a
particular wallet.
2.  A series of functions that allow editing wallets directly (eg. creating or
deleting wallets).

### 1.1: KWalletConnection

The KWalletConnection class minimizes the amount of state that you need to keep
track of. Initialize an object with the name of the wallet, and the name of your
application, and then use its methods to read and write key-value pairs to it's
folders.

As an example, the following code connects to a wallet, creates a folder, writes
a single entry to that folder, and then reads the value associated with the entry's
key.

    require './kwalletd5-ruby-interface'
    include KWalletd5

    # Open Wallet
    wc = KWalletd5::KWalletConnection.new("some-wallet", "my-application")

    # Create Folder
    wc.create_folder("my-app-folder")

    # Write Entry
    wc.write_entry("my-app-folder", "username1", "ins3cure_passw0rd")

    # Read Entry
    password = wc.read_entry("my-app-folder", "username")

#### List of KWalletConnection methods

The KWalletConnection class provides the following methods:

    # Operations Relating to Keys (does not care about type)
    replace_key(folder, old_key, new_key)
    list_keys(folder)
    does_key_exist(folder, key)

    # Operations for Entries
    write_entry(folder, key, value)
    lookup_entry(folder, key)
    delete_entry(folder, key)

    # Operations for Passwords
    write_password(folder, key, value)
    lookup_password(folder, key)

    # Operations for Maps
    write_map(folder, key, value)
    lookup_map(folder, key)

    # Operations for Folders
    create_folder(folder)
    delete_folder(folder)
    list_folders
    does_folder_exist(folder)

    # Operations for Connection Status
    is_open
    close!

_Note:_ See "2. Understanding the KDE Wallet (KWallet)" for information about the
differences between entry, password, and map.

### 1.2: Direct Functions

Outside of the KWalletConnection class, this module provides a set of functions
that interact with KWallet, without requiring permission to access a specific
wallet. These functions manage the creation and deletion of wallets - and can
read which applications/users have been authorized to access a wallet.

#### List of Direct Functions

This module provides the following functions:

    change_wallet_password(wallet_name, app_name, window_id: "0")
    list_wallets
    list_users(wallet_name)
    delete_wallet(wallet_name)
    is_wallet_open(wallet_name)
    does_wallet_exist(wallet_name)

## 2. Understanding the KDE Wallet (KWallet)

KWallet is a program developed for the KDE desktop to help keep the passwords of
various users secured (at least from other, unauthorized, users). It stores
key-value pairs in groups called 'wallets'. Each wallet can have any number of
folders, and each folder can store any number of key-value pairs. The key-value
pairs can be one of three kinds: entries, passwords, or maps. While KWallet stores
each type in a different format, when accessing them via the Qt DBUS they have
only one noteworthy difference: only the entries can be deleted.

The passwords and the maps can have their key changed, and can have their value
replaced (so you can functionally delete either type), but there is no way to
directly delete them via the Qt DBus interface.

I can't figure out if that is on purpose, or an oversight.

Otherwise, these three types are the same. Even though KWallet stores these key-value
pairs differently internally, when you access them through the Qt DBus everything
gets converted to a string.

On to the concept of a wallet. When KWallet is started, all wallets are 'closed'.
To open a wallet, a program requests access to a wallet (provided in this interface
by initializing a KWalletConnection). KWallet will prompt the user to enter their
password to open a wallet. This prompt is in a pop-up, but the pop-up can be associated
with a particular window (through the window_id).

If a wallet is already open when a program requests access to it (for the first
time), then the program will be given access. Depending on the user's configuration,
this might involve KWallet prompting the user (via a popup) to authorize the access,
but it seems that the default is to silently authorize the access.

This means that storing tokens or passwords in the KDE Wallet is not the most
secure method in the world (as other programs can likely silently get access to
the token or password). To make the system more secure, you can force-close
the wallet provided via the .close! method) immediately after reading or writing
 to it; but it's better to just avoid storing extremely important passwords in
 KWallet.

## 3. Understanding the Qt DBUS

The Qt DBus documentation is great, so just head over there and check it out:
https://doc.qt.io/qt-5/qtdbus-index.html
