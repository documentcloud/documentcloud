desc "List the current git branch"
task :branch do
  sh "git branch -v"
end

# Switch to a given git branch.
rule(/^branch:/) do |t|
  branch = t.name.split(':').last
  sh "git fetch"
  sh "git branch -f #{branch} origin/#{branch}"
  sh "git checkout #{branch}"
end
