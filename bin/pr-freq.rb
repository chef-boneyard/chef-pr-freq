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

require 'pp'

class PullRequestFrequency
  def initialize(repo = 'chef/chef')
    @api_token = api_token
    @client    ||= client
    @repo      = repo
  end

  attr_accessor :api_token, :client
  attr_accessor :pulls, :repo, :repo_tags

  def api_token
    File.read(File.join(File.expand_path('~'), '.github', 'api_token')).chomp
  end

  def client
    require 'octokit'
    Octokit::Client.new(access_token: api_token, auto_paginate: true)
  end

  def pulls
    @pulls ||= self.client.pull_requests(self.repo, state: 'closed')
  end

  def repo_tags
    @repo_tags ||= self.client.tags(self.repo)
  end
end

def date_between?(date, early, late)
  date >= early && date <= late
end

def days_or_hours(num)
  hours = num / 3600
  if hours > 24
    days = hours / 24
  else
    return "#{hours.round(2)} hours"
  end
  return "#{days.round(2)} days"
end

prf = PullRequestFrequency.new

desired_tags = prf.repo_tags.select do |t|
  t[:name].match(/^(\d+)\.(\d+)\.(\d+)$/) && $1.to_i >= 12
end

desired_tag_data = {}

desired_tags.each do |t|
  commit_data = prf.client.commit(prf.repo, t[:commit][:sha])
  desired_tag_data[t[:name]] = {
                                sha: t[:commit][:sha],
                                date: commit_data[:commit][:committer][:date]
                               }
end

pr_data = {}
release_data = {}
prf.pulls.each do |pr|
  desired_tag_data.keys.reverse.each_cons(2) do |v|
    if pr[:merged_at] && date_between?(pr[:merged_at],
                                       desired_tag_data[v.first][:date],
                                       desired_tag_data[v.last][:date])
      release_data[v.last] ||= {}
      release_data[v.last][:pulls] ||= []
      pr_data[pr[:number]] = {
                              sha: pr[:head][:sha],
                              merged: pr[:merged_at],
                              duration: pr[:merged_at] - pr[:created_at],
                              time_to_release: desired_tag_data[v.last][:date] - pr[:created_at]
                             }
      release_data[v.last][:pulls] << pr_data[pr[:number]]
      release_data[v.last][:avg_duration] = release_data[v.last][:pulls].map {|k| k[:duration]}.inject(:+).to_f / release_data[v.last][:pulls].count
      release_data[v.last][:avg_ttr] = release_data[v.last][:pulls].map {|k| k[:time_to_release]}.inject(:+).to_f / release_data[v.last][:pulls].count
    end
  end
end

release_data.each do |version, data|
  puts "Version: #{version}"
  puts "Total PRs: #{data[:pulls].count}"
  puts "Average duration PRs were open: #{days_or_hours(data[:avg_duration])}"
  puts "Average creation-to-release of PRs: #{days_or_hours(data[:avg_ttr])}"
  puts "------------------------------------------------------"
end

# Spark it up!
# brew install spark
# https://github.com/holman/spark
def spark(data)
  require 'mixlib/shellout'
  Mixlib::ShellOut.new("spark #{data}").run_command.stdout
end

# PR total
puts 'Total PRs'
puts spark release_data.map {|v, d| d[:pulls].count}.reverse.join(' ')
# duration open
puts 'Average duration PRs were open'
puts spark release_data.map {|v, d| (d[:avg_duration] / 3600).round(2)}.reverse.join(' ')
# duration to release
puts 'Average creation-to-release of PRs'
puts spark release_data.map {|v, d| (d[:avg_ttr] / 3600).round(2)}.reverse.join(' ')
