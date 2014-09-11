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
require_relative 'resource_app_console'

class Chef
  class Provider
    class AppConsole < Chef::Provider
      def load_current_resource
        @current_resource ||= Chef::Resource::AppConsole.new(new_resource.name)
        @current_resource.app(new_resource.name)
        @current_resource.command(new_resource.command)
        @current_resource.env(new_resource.env)
        @current_resource.verbosity(new_resource.verbosity)
        @current_resource.provider(new_resource.provider)
        @current_resource.user(new_resource.user)
        @current_resource.group(new_resource.group)

        @current_resource.run_context = new_resource.run_context
      end

      def action_run
        converge_by("Executing #{ @current_resource.command }") do
          execute_console_command
        end
      end

      def execute_console_command

        executor = Chef::Resource::Execute.new('symfony_project_app_console_' + Time.now.utc.strftime("%Y%m%d%H%M%S"))
        executor.provider(Chef::Provider::Execute)
        executor.cwd(@current_resource.app)
        verbosity = 'v' * @current_resource.verbosity
        executor.command("php app/console #{ @current_resource.command } --env=#{ @current_resource.env } -#{ verbosity }")
        executor.user(@current_resource.user)
        executor.group(@current_resource.group)
        executor.run_action(:run)

      end
    end
  end
end