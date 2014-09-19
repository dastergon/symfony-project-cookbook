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
require 'chef/log'
require_relative 'resource_app_console'

class Chef
  class Provider
    class AppConsole < Chef::Provider
      def load_current_resource
        @current_resource ||= Chef::Resource::AppConsole.new(new_resource.name)
        @current_resource.app(new_resource.app)
        @current_resource.command(new_resource.command)
        @current_resource.environment(new_resource.environment)
        @current_resource.verbosity(new_resource.verbosity)
        @current_resource.provider(new_resource.provider)
        @current_resource.user(new_resource.user)
        @current_resource.group(new_resource.group)
        @current_resource.console(new_resource.console)
        @current_resource.run_context = new_resource.run_context
      end

      def action_run
          execute_console_command
      end

      def execute_console_command
        cmd = "#{ @current_resource.console } #{ @current_resource.command } --env=#{ @current_resource.environment.to_s } --verbose=#{ @current_resource.verbosity } --no-ansi --no-interaction"
        Chef::Log.info 'APP_CONSOLE: Running ' + cmd
        converge_by("Executing #{ @current_resource.command }") do
          executor = Chef::Resource::Execute.new('symfony-app-console', @run_context)
          executor.cwd(@current_resource.app)
          executor.command(cmd)
          executor.user(@current_resource.user)
          executor.group(@current_resource.group)
          executor.run_action(:run)
        end
      end
    end
  end
end