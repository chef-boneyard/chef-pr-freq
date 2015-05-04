task :default => :setup

desc 'Setup your machine to use the script'
task :setup do
  sh(%Q{chef-apply --minimal-ohai -e 'Chef::Log.warn("Its probably fine."); chef_gem("octokit") { compile_time false }; package "spark"'})
  if !::File.exists?(File.join(File.expand_path('~'), '.github', 'api_token'))
    raise 'You need to create ~/.github/api_token with your GitHub credentials!'
  end
end
