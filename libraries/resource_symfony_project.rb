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

require 'chef/resource'
require_relative 'provider_symfony_project'
require_relative 'provider_permission_setfacl'

class Chef
  class Resource
    class SymfonyProject < Chef::Resource::Deploy
      def initialize(name, run_list=nil)
        super(name, run_list)
        @resource_name = :symfony_project
        @provider = Chef::Provider::SymfonyProject::Timestamped
        @allowed_actions.push(:set_permissions)
        @shared_dirs = {
            'logs' => 'app/logs',
            'cache' => 'app/cache',
            'uploads' => 'web/media/uploads'
        }
        @create_dirs_before_symlink = ['web/media/uploads']
        @symlinks = @shared_dirs
        @permission_provider = Chef::Provider::SymfonyPermission::Setfacl
        @web_user = 'www-data'
        @purge_before_symlink.clear
        @symlink_before_migrate.clear
        @composer_options = {
           :action => :install,
           :lock_file_only => true,
           :dev => false,
           :prefer_dist => true,
           :prefer_source => false,
           :optimize_autoloader => true,
           :download_phar => true
        }
        @parameters = {}
        @parameters_dist_file = 'app/config/parameters.yml.dist'
        @parameters_file = 'app/config/parameters.yml'
      end

      def shared_dirs(arg=nil)
        set_or_return(:shared_dirs, arg, :kind_of => Hash)
        symlinks(arg)
      end

      def permission_provider(arg=nil)
        set_or_return(:permission_provider, arg, :kind_of => Class)
      end

      def web_user(arg=nil)
        set_or_return(:web_user, arg, :kind_of => String)
      end

      def composer_options(arg=nil)
        return @composer_options if arg.nil?
        options = @composer_options.clone
        options = options.merge(arg)
        set_or_return(:composer_options, options, :kind_of => Hash)
      end

      def composer_option(option, value=nil)
        @composer_options[option] = value
      end

      def parameters(arg=nil)
        set_or_return(:parameters, arg, :kind_of => Hash)
      end

      def parameters_dist_file(arg=nil)
        set_or_return(:parameters_dist_file, arg, :kind_of => String)
      end

      def parameters_file(arg=nil)
        set_or_return(:parameters_file, arg, :kind_of => String)
      end
    end
  end
end