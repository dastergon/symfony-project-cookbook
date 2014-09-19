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
          @new_resource.composer_options.each do |method, arg|
            composer.send method, arg
          end
          composer.user @new_resource.user
          composer.group @new_resource.group
          create_parameter_file
          coll = Chef::ResourceCollection.new
          context = run_context.dup
          coll << composer
          context.resource_collection = coll
          runner = Chef::Runner.new(context)
          runner.converge
        end
      end

      def create_parameter_file

        return if @new_resource.parameters_file_template.nil?

        parameters = YAML.load_file "#{ release_path }/#{ @new_resource.parameters_dist_file }"
        parameters['parameters'] = parameters['parameters'].merge(@new_resource.parameters)
        template_cookbook = (@new_resource.parameters_file_template_cookbook || @new_resource.cookbook_name || 'activelamp_symfony').to_s

        Chef::Log.info "Creating parameter file (#{ @new_resource.parameters_file })..."
        converge_by("Creating parameter file (#{ @new_resource.parameters_file })...") do
          template = Chef::Resource::Template.new("#{ release_path}/#{ @new_resource.parameters_file}", run_context)
          template.cookbook template_cookbook
          template.source @new_resource.parameters_file_template
          template.owner @new_resource.user
          template.group @new_resource.group
          template.variables({
            :parameters => parameters
          })
          template.run_action(:create_if_missing)
        end
      end

      def release_slug
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def action_set_permissions
        converge_by("Setting permission #{ @current}") do
          verify_directories_exist
          @permission_provider.release_path release_path
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