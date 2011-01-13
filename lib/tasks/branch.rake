desc "List the current git branch"
task :branch do
  sh "git branch -v"
end

# Switch to a given git branch.
rule(/^branch:/) do |t|
  branch = t.name.split(':').last
  remote = `git remote`.split(/\n/).first
  sh "git fetch"
  sh "git branch -f #{branch} #{remote}/#{branch}"
  sh "git checkout #{branch}"
end
