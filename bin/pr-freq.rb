#!/usr/bin/env ruby
# Author: Joshua Timberman <joshua@chef.io>
# Copyright: Chef Software, Inc. <legal@chef.io>
#
# https://twitter.com/jtimberman/status/576421331874418690
# "OH 'that looks like a bash script and a text file filtered through a ruby lens'"
#
# Brought to you by itsprobablyfine.jpg, and #worksonmymachine
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

path = __FILE__
while File.symlink?(path)
  path = File.expand_path(File.readlink(__FILE__), File.dirname(__FILE__))
end
$:.unshift(File.join(File.dirname(File.expand_path(path)), '..', 'lib'))

require 'chef-pr-freq'

Chef::PullRequestCalculator.new.calculate