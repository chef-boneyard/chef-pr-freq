class Chef
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
end
