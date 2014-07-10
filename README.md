Paperclip Database Storage
==========================

Paperclip Database Storage is an additional storage option for
Paperclip. It give you the opportunity to store your paperclip binary
file uploads in the database along with all your other data.

Why I forked
------------
I realised that in my opinion few things can be done better.
- there is no need for multiple tables. Only one is required, rest can be done by polymorphic association.
- there is no need to create separate controller for serving attachment files. I created middleware that do this job.


Installation
------------

    gem "paperclip_database", git: 'https://github.com/kubenstein/paperclip_database.git'


Usage
-----

You use `paperclip_database` by specifying `database` as storage for
your paperclip and create a migration for the additional database
table.

In your model:

    class User < ActiveRecord::Base
      has_attached_file :avatar, 
                        :storage => :database ## This is the essence
                        :styles => { :medium => "300x300>", :thumb => "100x100>" }
    end

There is a migration generator that will create a basic migration for
the extra table.

    rails generate paperclip_database:migration install


Credits
-------
Jarl Friis (https://github.com/jarl-dk)

