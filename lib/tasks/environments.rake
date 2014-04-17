%w[development production staging test].each do |env|
  desc "Runs the following task in the #{env} environment"
  task env do
    RAILS_ENV = ENV['RAILS_ENV'] = env
    Rails.env = RAILS_ENV if defined?(Rails)
  end
end

