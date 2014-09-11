#
# Author:: Bez Hermoso (<bez@activelamp.com>)
# Copyright:: Copyright (c) 2014 ActiveLAMP
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permission and
# limitations under the License.
#

actions :deploy, :revision, :set_permissions
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