Devise LDAP Authenticatable - Based on Devise-Imapable
=================

Devise LDAP Authenticatable is a LDAP based authentication strategy for the [Devise](http://github.com/plataformatec/devise) authentication framework.

If you are building applications for use within your organization which require authentication and you want to use LDAP, this plugin is for you.

Requirements
------------

- Rails 3.0.0.beta4
- Devise 1.1.rc2
- ruby-net-ldap 0.0.4

Installation
------------

	gem install devise_ldap_authenticatable

and
	
	config.gem 'devise_ldap_authenticatable'

Setup
-----

Once devise\_ldap\_authenticatable is installed, all you need to do is setup the user model which includes a small addition to the model itself and to the schema.

First the schema :

    create_table :users do |t|
      t.ldap_authenticatable, :null => false
    end

and indexes (optional) :

    add_index :login, :unique => true

and don’t forget to migrate :

    rake db:migrate.

then the model :

    class User < ActiveRecord::Base
      devise :ldap_authenticatable, :rememberable, :trackable, :timeoutable

      # Setup accessible (or protected) attributes for your model
      attr_accessible :login, :password, :remember_me
      ...
    end

and finally change the authentication key in the devise initializer :

	Devise.setup do |config|
	  ...
	  config.authentication_keys = [ :login ]
	  ...
	end

I recommend using :rememberable, :trackable, :timeoutable as it gives a full feature set for logins.

Usage
-----

Devise LDAP Authenticatable works in replacement of Authenticatable, 
but because we have to change the authentication\_keys, you'll need to run:

    script/generate devise_views

and customize your login pages to use :login, instead of :email.

------------------------------------------------------------

**_Please Note_**

This devise plugin has not been tested with Authenticatable enabled at the same time. This is meant as a drop in replacement for Authenticatable allowing for a semi single sign on approach.


Configuration
----------------------

In initializer  `config/initializers/devise.rb` :

    Devise.setup do |config|
      # Required
      config.ldap_host = 'ldap.mydomain.com'
      config.ldap_port = 389
	  config.ldap_base_dn = 'ou=People,dc=local'
	  config.ldap_login_attribute = 'uid'
	
	  # Optional, these will default to false or nil if not set
	  config.ldap_ssl = true
	  config.ldap_create_user = true
    end

* ldap\_host
	* The host of your LDAP server
	
* ldap\_port
	* The port your LDAP service is listening on.
	
* ldap\_base_dn
	* The DN that is appended to the login before the LDAP bind is performed.
	
* ldap\_login_attribute
	* The attribute that is prepended to the login and the base dn to form the
	  full DN that is used for the bind.
	* Example:
		* config.ldap\_base_dn = 'ou=People,dc=local'
		* config.ldap\_login_attribute = 'uid'
		* So when trying to login with 'admin' for example, 'admin' would be
		  the value stored in login field, but the actual DN used for the bind
		  would be 'uid=admin,ou=People,dc=local'
		
* ldap\_ssl
	* Enables SSL (ldaps) encryption.  START_TLS encryption will be added when the net-ldap gem adds support for it.

* ldap\_create\_user
	* If set to true, all valid LDAP users will be allowed to login and an appropriate user record will be created.
      If set to false, you will have to create the user record before they will be allowed to login.


References
----------

* [Devise](http://github.com/plataformatec/devise)
* [Warden](http://github.com/hassox/warden)


TODO
----

- Add support for defining DN format to make logins cleaner
- Tests

Released under the MIT license

Copyright (c) 2010 Curtis Schiewek
