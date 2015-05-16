require 'pp'

require 'chef-pr-freq/pull_request_frequency'

class Chef

  class PullRequestCalculator

    # Spark it up!
    # brew install spark
    # https://github.com/holman/spark
    def spark(data)
      require 'mixlib/shellout'
      Mixlib::ShellOut.new("spark #{data}").run_command.stdout
    end

    def calculate
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

      # PR total
      puts 'Total PRs'
      puts spark release_data.map {|v, d| d[:pulls].count}.reverse.join(' ')
      # duration open
      puts 'Average duration PRs were open'
      puts spark release_data.map {|v, d| (d[:avg_duration] / 3600).round(2)}.reverse.join(' ')
      # duration to release
      puts 'Average creation-to-release of PRs'
      puts spark release_data.map {|v, d| (d[:avg_ttr] / 3600).round(2)}.reverse.join(' ')

    end

  end

end
