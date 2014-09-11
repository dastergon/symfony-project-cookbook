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
require_relative 'provider_app_console'

class Chef
  class Resource
    class AppConsole < Chef::Resource
      def initialize(name, run_list=nil)
        super
        @resource_name = :app_console
        @action = :run
        @allowed_actions = [:run]
        @provider = Chef::Provider::SymfonyProject::AppConsole

        @app = name
        @env = 'dev'
        @command = ''
        @verbosity = ''
        @user = nil
        @group = nil
      end

      def env(arg=nil)
        set_or_return(:env, arg, :kind_of => String)
      end

      def command(arg=nil)
        set_or_return(:command, arg, :kind_of => String)
      end

      def verbosity(arg=nil)
        set_or_return(:verbosity, arg, :kind_of => Fixnum)
      end

      def app(arg=nil)
        set_or_return(:app, arg, :kind_of => String)
      end

      def user(arg=nil)
        set_or_return(:user, arg, :kind_of => [String, NilClass])
      end

      def group(arg=nil)
        set_or_return(:group, arg, :kind_of => [String, NilClass])
      end
    end
  end
end