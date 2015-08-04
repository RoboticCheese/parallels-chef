# Encoding: UTF-8
#
# Cookbook Name:: parallels
# Library:: resource_parallels_config
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

require 'chef/resource/lwrp_base'

class Chef
  class Resource
    # A resource for Parallels Desktop's license configuration.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ParallelsConfig < Resource::LWRPBase
      self.resource_name = :parallels_config
      actions :create
      default_action :create

      #
      # Attribute for an optional Parallels license key
      #
      attribute :license, kind_of: String, default: nil
    end
  end
end
