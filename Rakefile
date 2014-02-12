require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:test) do |t|
    t.rspec_opts = "--color"
end

RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = "--format=documentation --color"
end

task :build do
    system "gem build imgsort.gemspec"
end
