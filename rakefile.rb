# frozen_string_literal: true

require "bundler/gem_tasks"

require "minitest/test_task"

Minitest::TestTask.create(:test) do |t|
  t.test_globs = ["spec/**/*_spec.rb"]
  t.verbose = false
  t.warning = true
end

task default: :test
