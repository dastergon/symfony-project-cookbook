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

require 'chef/provider'
require 'chef/mixin/deep_merge'
require 'yaml'
YAML::ENGINE.yamler = 'syck'

class Chef
  class Provider
    class SymfonyProject < Chef::Provider::Deploy

      include Chef::Mixin::DeepMerge

      def initialize(new_resource, run_context)
        super(new_resource, run_context)
        @permission_provider = new_resource.permission_provider.new(new_resource, run_context)
      end

      def install_gems
        Chef::Log.info 'Gathering Composer dependencies...'
        converge_by("Gathering Composer dependencies...") do
          break if @new_resource.composer_options[:action] == :nothing
          composer = Chef::Resource::Composer.new(release_path, run_context)
          download_phar = @new_resource.composer_options[:download_phar]
          @new_resource.composer_options.delete(:download_phar)
          @new_resource.composer_options.each do |method, arg|
            composer.send method, arg
          end
          composer.user @new_resource.user
          composer.group @new_resource.group
          composer.run_action :download_phar if download_phar and @new_resource.composer_options[:action] != :download_phar
          create_parameter_file
          composer.run_action @new_resource.composer_options[:action]
        end
      end

      def create_parameter_file
        Chef::Log.info "Creating parameter file (#{ @new_resource.parameters_file })..."
        parameters = YAML.load_file "#{ release_path }/#{ @new_resource.parameters_dist_file }"
        parameters['parameters'] = parameters['parameters'].merge(@new_resource.parameters)
        file = ::File.open "#{ release_path }/#{ @new_resource.parameters_file }", 'w'
        file.write parameters.to_yaml
        file.close
      end

      def release_slug
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def action_set_permissions
        converge_by("Setting permission #{ @current}") do
          verify_directories_exist
          @permission_provider.release_slug release_slug
          @permission_provider.action_set_permissions
        end
      end

      def verify_directories_exist
        super
        @new_resource.shared_dirs.each_key do |target|
          create_dir_unless_exists @new_resource.shared_path + '/' + target
        end
      end
    end
  end
end