require 'rails_html_validator/version'
require 'rails_html_validator/html_validator'

begin
  require 'rspec'
rescue LoadError
end

require 'rails_html_validator/matcher' if defined?(RSpec)
