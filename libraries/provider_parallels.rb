# Encoding: UTF-8
#
# Cookbook Name:: parallels
# Library:: provider_parallels
#
# Copyright 2015 Jonathan Hartman
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
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/provider/lwrp_base'
require_relative 'resource_parallels'
require_relative 'resource_parallels_app'
require_relative 'resource_parallels_config'

class Chef
  class Provider
    # A parent Chef provider for the Parallels app and config.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class Parallels < Provider::LWRPBase
      PATH ||= '/Applications/Parallels Desktop.app'

      use_inline_resources

      provides :parallels, platform_family: 'mac_os_x'

      #
      # WhyRun is supported by this provider.
      #
      # @return [TrueClass, FalseClass]
      #
      def whyrun_supported?
        true
      end

      #
      # Use the parallels_app resource to perform an install.
      #
      action :install do
        parallels_app 'default' do
          version new_resource.version
          action :install
        end
      end

      #
      # Use the parallels_app resource to perform a removal.
      #
      action :remove do
        parallels_app 'default' do
          action :remove
        end
      end

      #
      # Use the parallels_config resource to configure Parallels.
      #
      action :configure do
        parallels_config 'default' do
          license new_resource.license
          action :create
        end
      end
    end
  end
end
