actions :deploy, :revision
default_action :deploy

attribute :destination, :name_attribute => true, :kind_of => String, :required => true
attribute :repo, :kind_of => String
attribute :revision, :kind_of => String
attribute :user, :kind_of => String
attribute :group, :kind_of => String
attribute :shared_web_dirs, :kind_of => Array
attribute :ssh_wrapper, :kind_of => [String, NilClass]
attribute :keep_releases, :kind_of => Fixnum
attribute :shared_vendor, :kind_of => [TrueClass, FalseClass], :default => true
attribute :acl_method, :kind_of => String, :default => 'setfacl'
attribute :web_user, :kind_of => String, :default => 'www-data'
attribute :deploy_provider, :kind_of => Class, :default => Chef::Provider::Deploy::Timestamped