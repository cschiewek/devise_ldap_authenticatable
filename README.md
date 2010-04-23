Devise LDAP Authenticatable - Based on Devise-Imapable
=================

Devise LDAP Authenticatable is a LDAP based authentication strategy for the [Devise](http://github.com/plataformatec/devise) authentication framework.

If you are building applications for use within your organization which require authentication and you want to use LDAP, this plugin is for you.

Requirements
------------

Rails 2.3.5
Devise 1.0.6
Net-LDAP 0.1.1 (You must use the net-ldap gem, NOT the ruby-net-ldap gem.)

Installation
------------

script/plugin install git@github.com:cschiewek/devise\_ldap\_authenticatable.git

Setup
-----

Once devise\_ldap\_authenticatable is installed, all you need to do is setup the user model which includes a small addition to the model itself and to the schema.

First the schema :

    create_table :users do |t|
      t.ldap_authenticatable
    end

and indexes (optional) :

    add_index :ldap_login, :unique => true

and don’t forget to migrate :

    rake db:migrate.

then finally the model :

    class User < ActiveRecord::Base
      devise :ldap_authenticatable, :rememberable, :trackable, :timeoutable

      # Setup accessible (or protected) attributes for your model
      attr_accessible :ldap_login, :password, :remember_me
      ...
    end

I recommend using :rememberable, :trackable, :timeoutable as it gives a full feature set for logins.

Usage
-----

Devise LDAP Authenticatable works in replacement of Authenticatable, allowing for LDAP authentication via simple bind. The standard sign\_in routes and views work out of the box as these are just reused from devise. I recommend you run :

    script/generate devise_views

so you can customize your login pages.

------------------------------------------------------------

**please note**

This devise plugin has not been tested with Authenticatable enabled at the same time. This is meant as a drop in replacement for Authenticatable allowing for a semi single sign on approach.


Configuration
----------------------

In initializer  `config/initializers/devise.rb` :

    Devise.setup do |config|
      # ...
      config.ldap_host = 'ldap.mydomain.com'
      config.ldap_port = 389
      # ...
    end

So remember ...
---------------

- don't use Authenticatable

- add ldap\_host and ldap\_port settings in the devise initializer

- generate the devise views and make them pretty


References
----------

* [Devise](http://github.com/plataformatec/devise)
* [Warden](http://github.com/hassox/warden)


TODO
----

- Add support for SSL/TLS
- Add support for defining DN format to make logins cleaner
- Tests

Released under the MIT license

Copyright (c) 2010 Curtis Schiewek
