require "nokogiri"

RSpec::Matchers.define :exclude_html_tag_of do |value, tag:|
  match do |model|
    html = "<#{tag.to_s}></#{tag.to_s}>"
    model.try("#{value}=", html)
    !model.valid?
  end
end
