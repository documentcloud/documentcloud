# A sample Guardfile
# More info at https://github.com/guard/guard#readme

notification :growl

guard :minitest, :all_on_start => true, :spring => 'rake test' do

  watch(%r{^test/test_helper\.rb}) { 'test' }
  watch(%r{^test/.+_test\.rb})

  watch(%r{^test/fixtures/(.+)s\.rb})                    { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r{^app/(.+)\.rb})                               { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^app/controllers/application_controller\.rb}) { 'test/controllers' }
  watch(%r{^app/controllers/(.+)_controller\.rb})        { |m| "test/controllers/#{m[1]}_controller_test.rb" }
  watch(%r{^app/models/(.+)\.rb})                        { |m| "test/models/#{m[1]}_test.rb" }

  watch(%r{^app/views/(.+)_mailer/.+})                   { |m| "test/mailers/#{m[1]}_mailer_test.rb" }
  watch(%r{^app/mailers/(.+)\.rb})                       { |m| "test/mailers/#{m[1]}_test.rb" }
  watch(%r{^lib/(.+)\.rb})                               { |m| "test/lib/#{File.basename(m[1],'.rb')}_test.rb" }

end

guard 'bundler' do
  watch('Gemfile')
end
