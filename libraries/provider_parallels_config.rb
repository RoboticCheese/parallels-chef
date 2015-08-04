# Encoding: UTF-8
#
# Cookbook Name:: parallels
# Library:: provider_parallels_config
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
require_relative 'resource_parallels_config'

class Chef
  class Provider
    # A Chef provider for Parallels configuration.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ParallelsConfig < Provider::LWRPBase
      use_inline_resources

      provides :parallels_config, platform_family: 'mac_os_x'

      #
      # WhyRun is supported by this provider.
      #
      # @return [TrueClass, FalseClass]
      #
      def whyrun_supported?
        true
      end

      #
      # Use an execute resource to feed the license key, if offered, to
      # Parallels.
      #
      action :create do
        ctl = ::File.join(Parallels::PATH, 'Contents/MacOS/prlsrvctl')
              .gsub(' ', '\\ ')
        execute 'Install Parallels license' do
          command "#{ctl} install-license -k #{new_resource.license}"
          action :run
          only_if { new_resource.license }
          not_if "#{ctl} info --license | grep 'status=\"ACTIVE\"'"
        end
      end
    end
  end
end
