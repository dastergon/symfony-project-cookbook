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

class Chef
  class Provider
    class SymfonyProjectDeploy < Chef::Provider::Deploy
      def initialize(new_resource, run_context)
        super(new_resource, run_context)
        @permission_provider = new_resource.permission_provider.new(new_resource, run_context)
      end

      def release_slug
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def action_set_permissions
        converge_by("Setting permission #{ @current}") do
          @permission_provider.release_slug(release_slug)
          @permission_provider.action_set_permissions
        end
      end

      def verify_directories_exist
        super
        @new_resource.shared_dirs.each_key do |target|
          create_dir_unless_exists(@new_resource.shared_path + '/' + target)
        end
      end
    end
  end
end