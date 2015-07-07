# Encoding: UTF-8
#
# Cookbook Name:: parallels
# Library:: provider_parallels_app_mac_os_x
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

require 'net/http'
require 'chef/provider/lwrp_base'
require_relative 'provider_parallels_app'

class Chef
  class Provider
    class ParallelsApp < Provider::LWRPBase
      # An provider for Parallels for Mac OS X.
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class MacOsX < ParallelsApp
        PATH ||= '/Applications/Parallels Desktop.app'

        private

        #
        # Use a dmg_package resource to download and install the package. The
        # dmg_resource creates an inline remote_file, so this is all that's
        # needed.
        #
        # (see ParallelsApp#install!)
        #
        def install!
          s = remote_path
          v = version
          dmg_package 'Parallels Desktop' do
            source s
            volumes_dir "Parallels Desktop #{v}"
            action :install
          end
        end

        #
        # For lack of a package manager, delete all of Parallels' directories.
        #
        # (see ParallelsApp#remove!)
        #
        def remove!
          [
            PATH,
            '/Applications/Parallels Access.app'
          ].each do |d|
            directory d do
              recursive true
              action :delete
            end
          end
        end

        #
        # Use the resource's version attribute to construct a Parallels URL,
        # then follow the redirect to a .dmg file.
        #
        # @return [String] a download URL
        #
        def remote_path
          @remote_path ||= begin
            # While www. is served up over HTTPS, it still redirects to an HTTP
            # download, so let's not both with configuring SSL.
            uri = URI("http://www.parallels.com/directdownload/pd#{version}/")
            Net::HTTP.get_response(uri)['location']
          end
        end

        #
        # Return either the new_resource's version or, eventually, have logic
        # that can dynamically figure out what the latest major version is.
        #
        # @return [String] a version string for this provider to use
        #
        def version
          new_resource.version # TODO: || Parallels::Helpers.latest_version
        end
      end
    end
  end
end
