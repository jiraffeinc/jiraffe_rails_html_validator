require "nokogiri"

module RailsHtmlValidator
  module Matchers
    ::RSpec::Matchers.define :exclude_html_tag_of do |attribute, tag:|
      match do |model|
        html = "<#{tag.to_s}></#{tag.to_s}>"
        model.try("#{attribute}=", html)

        validators = model._validators[attribute].select do |v|
          v.class == ActiveModel::Validations::HtmlValidator
        end
        return false if validators.blank?

        validators.first.validate_each(model, attribute, html)
        p model.errors.messages[attribute]
        model.errors.messages[attribute].length > 0
      end
    end
  end
end
