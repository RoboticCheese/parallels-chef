# Encoding: UTF-8
#
# Cookbook Name:: parallels
# Library:: resource_parallels
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

require 'chef/resource'
require_relative 'resource_parallels_app'
require_relative 'resource_parallels_config'

class Chef
  class Resource
    # A parent Chef custom resource for Parallels Desktop's app and config.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class Parallels < Resource
      PATH ||= '/Applications/Parallels Desktop.app'

      provides :parallels, platform_family: 'mac_os_x'

      #
      # Allow a user to install a major version of Parallels.
      #
      property :version,
                kind_of: [String, Fixnum, nil],
                default: '10',
                callbacks: { 'Not a valid major version' =>
                               lambda do |a|
                                 a.is_a?(Fixnum) || !a.match(/^[0-9]+$/).nil?
                               end }

      #
      # Property for an optional Parallels license key
      #
      property :license, kind_of: [String, nil], default: nil

      #
      # TODO: Property for an optional specific package URL.
      #
      # property :source, kind_of: [String, nil], default: nil

      default_action [:install, :configure]

      #
      # Use the parallels_app resource to perform an install.
      #
      action :install do
        parallels_app 'default' do
          version new_resource.version
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
        end
      end
    end
  end
end
