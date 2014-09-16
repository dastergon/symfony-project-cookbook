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
require_relative 'provider_permission'

class Chef
  class Provider
    class SymfonyPermission
      class Setfacl < Chef::Provider::SymfonyPermission
        def set_permission(directory, user)
          resource = Chef::Resource::Execute.new("setfacl -R -m u:\"#{ user }\":rwX -m u:`whoami`:rwX #{ directory }", @run_context)
          resource.user(@new_resource.user)
          resource.group(@new_resource.group)
          resource.provider(Chef::Provider::Execute)
          resource.run_action(:run)

          resource = Chef::Resource::Execute.new("setfacl -dR -m u:\"#{ user }\":rwX -m u:`whoami`:rwX #{ directory }", @run_context)
          resource.user(@new_resource.user)
          resource.group(@new_resource.group)
          resource.provider(Chef::Provider::Execute)
          resource.run_action(:run)
        end
      end
    end
  end
end