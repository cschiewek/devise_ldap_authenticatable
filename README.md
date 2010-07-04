Devise LDAP Authenticatable - Based on Devise-Imapable
=================

Devise LDAP Authenticatable is a LDAP based authentication strategy for the [Devise](http://github.com/plataformatec/devise) authentication framework.

If you are building applications for use within your organization which require authentication and you want to use LDAP, this plugin is for you.

This is a fork of http://github.com/cschiewek/devise_ldap_authenticatable intended to be used with a Rails 3 application as a gem.

Requirements
------------

- Rails 3.0.0.beta4
- Devise 1.1.rc2
- ruby-net-ldap 0.0.4

Installation
------------

In the Gemfile for your application:

    gem "devise", "1.1.rc2"
    gem "devise_ldap_authenticatable", :git => "git@github.com:dpmcnevin/devise_ldap_authenticatable.git", :branch => "rails3"

Setup
-----

Copy the ldap.yml.sample to `#{Rails.root}/config/ldap.yml` and edit it with the settings for your LDAP server

I recommend using :rememberable, :trackable, :timeoutable as it gives a full feature set for logins.

Usage
-----

Devise LDAP Authenticatable works in replacement of Database Authenticatable

------------------------------------------------------------

**_Please Note_**

This devise plugin has not been tested with DatabaseAuthenticatable enabled at the same time. This is meant as a drop in replacement for DatabaseAuthenticatable allowing for a semi single sign on approach.


Configuration
----------------------

In initializer  `config/initializers/devise.rb` :

    Devise.setup do |config|
	    config.ldap_create_user = true
    end

* ldap\_create\_user
	* If set to true, all valid LDAP users will be allowed to login and an appropriate user record will be created.
      If set to false, you will have to create the user record before they will be allowed to login.

**_Please Note_**

Originally the LDAP settings were made in the initializer, but I have moved them to a .yml file for multiple environment support.

References
----------

* [Original Plugin](http://github.com/cschiewek/devise_ldap_authenticatable)
* [Devise](http://github.com/plataformatec/devise)
* [Warden](http://github.com/hassox/warden)


TODO
----

- Add configurable support for fields other than email (originally the plugin used login)
- Better compatibility with Rails 2 & 3, if possible.
- Add support for defining DN format to make logins cleaner
- Tests

Released under the MIT license

Copyright (c) 2010 Curtis Schiewek, Daniel McNevin
