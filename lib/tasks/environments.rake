%w[development production staging test].each do |env|
  desc "Runs the following task in the #{env} environment"
  task env do
    # While it appears to do so, this doesn't actually set the environment.
    #
    # Instead the environment is set by the ARGV check in the Rakefile in the rails root directory.
    # There are numerous spots in both our and the Rails codebase that cache the environment,
    # making it difficult/impossible to set inside a rake task.

    # These tasks still need to exist though, otherwise Rake will complain when it attempts
    # to call them.
  end
end
