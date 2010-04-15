Devise - LDAP Authenticatable - Based on Devise-Imapable
=================

Devise-Imapable is a imap based authentication strategy for the [Devise](http://github.com/plataformatec/devise) authentication framework.

If you are building applications for use within your organisation which require authentication and don't have access to a LDAP server, using imap can be a great alternative.

Installation
------------

**Please note that Devise-Imapable only works with Devise 1.0.5 at the moment, changes for 1.0.6 will be made soon**

Currently this can only be installed as a plugin.

    script/plugin install git@github.com:joshk/devise_imapable.git

*Now in gem form, install notes coming soon*


**And don't forget to add [Devise](http://github.com/plataformatec/devise)!**

either in config/environment.rb:

    config.gem 'devise'

or in bundler

    gem 'devise'


Setup
-----

Once devise-imapable is installed, all you need to do is setup the user model which includes a small addition to the model itself and to the schema.

First the schema :

    create_table :users do |t|

      t.imapable

    end

and indexes (optional) :

    add_index :users, :email, :unique => true

and don’t forget to migrate :

    rake db:migrate.

then finally the model :

    class User < ActiveRecord::Base

      devise :rememberable, :trackable, :timeoutable, :imapable

      # Setup accessible (or protected) attributes for your model
      attr_accessible :email, :password, :remember_me

      ...
    end

I recommend using :rememberable, :trackable, :timeoutable along with :imapable as it gives a full feature set for logins.


Usage
-----

Devise-Imapable works in replacement of Authenticatable, allowing for user name (or email) and password authentication. The standard sign\_in routes and views work out of the box as these are just reused from devise. I recommend you run :

    script/generate devise_views

so you can customize your login pages.

------------------------------------------------------------

**please note**

This devise plugin has not been tested with Authenticatable enabled at the same time. This is meant as a drop in replacement for Authenticatable allowing for a semi single sign on approach.


Advanced Configuration
----------------------

In initializer  `config/initializers/devise.rb` :

    Devise.setup do |config|
      # ...
      config.imap_server = 'bigcorporation.com'
      config.default_email_suffix = 'friendly-corporation.com'
      # ...
    end

Imap servers usually allow a user to login using their full email address or just the identifier part, eg: josh.kalderimis and josh.kalderimis@gmail.com will both work. It is recommend that you set the default\_email\_suffix so the login is kept consistent and the users email is correctly stored in the User model.

So remember ...
---------------

- don't use Authenticatable

- add imap\_server and default\_email\_suffix settings in the devise initializer

- generate the devise views and make them pretty


References
----------

* [Devise](http://github.com/plataformatec/devise)
* [Warden](http://github.com/hassox/warden)


TODO
----

- add notes about gem

- email validation

- add update\_with\_password to the model, similar to Authenticatable

- assert Authenticatable is not being used

- assert imap\_server is present, and warn if default\_email\_suffix isn't present

- tests, tests, tests

- allow for setups which require profile information before creating a user

- investigate how well this works with other devise modules like http\_authenticatable, token\_authenticatable lockable, confirmable, and activatable



Released under the MIT license

Copyright (c) 2010 Josh Kalderimis,
