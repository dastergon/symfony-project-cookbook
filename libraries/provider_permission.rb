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
require 'chef/exceptions'

class Chef
  class Provider
    class SymfonyPermission < Chef::Provider
      def initialize(new_resource, run_context=nil)
        super(new_resource, run_context)
        @release_slug = nil
      end

      def release_slug(arg=nil)
        if arg.nil? and !@release_slug.nil?
          return @release_slug
        elsif arg.nil?
          raise Chef::Exceptions::StandardError, "Release slug is not set yet."
        end
        @release_slug = arg
      end

      def action_set_permissions
        @new_resource.shared_dirs.each do |target, link|
          set_permission(@new_resource.shared_path + '/' + target, @new_resource.web_user)
        end
      end

      def set_permission(directory, user)
        raise Chef::Exceptions::Override, "You must override set_permission in #{self.to_s}"
      end
    end
  end
end