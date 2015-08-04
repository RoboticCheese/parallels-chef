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

require 'chef/resource/lwrp_base'

class Chef
  class Resource
    # A parent Chef resource for Parallels Desktop's app and config.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class Parallels < Resource::LWRPBase
      self.resource_name = :parallels
      actions :install, :remove, :configure
      default_action [:install, :configure]

      #
      # Allow a user to install a major version of Parallels.
      #
      attribute :version,
                kind_of: [NilClass, String, Fixnum],
                default: '10',
                callbacks: { 'Not a valid major version' =>
                               lambda do |a|
                                 a.is_a?(Fixnum) || !a.match(/^[0-9]+$/).nil?
                               end }

      #
      # TODO: Attribute for an optional specific package URL.
      #
      # attribute :source, kind_of: String, default: nil

      #
      # Attribute for an optional Parallels license key
      #
      attribute :license, kind_of: String, default: nil
    end
  end
end
