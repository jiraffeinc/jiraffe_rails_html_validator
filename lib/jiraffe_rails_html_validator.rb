require "jiraffe_rails_html_validator/version"
require 'active_model'
require 'active_support/i18n'
require 'nokogiri'
I18n.load_path += Dir[File.dirname(__FILE__) + "/locale/*.yml"]

module ActiveModel
  module Validations
    class HtmlValidator < ::ActiveModel::EachValidator
      def initialize(options)
        options.reverse_merge!(exclude_tags: [])
        super(options)
      end

      def validate_each(record, attribute, value)
        html = ::Nokogiri.HTML(value) {|config| config.strict}
        if html.errors.present?
          record.errors.add(attribute, I18n.t("errors.messages.html"))
          html.errors.each do |err|
            record.errors.add(attribute, err.message)
          end
        end

        options.fetch(:exclude_tags).each do |tag|
          if html.css(tag.to_s).present?
            record.errors.add(attribute, I18n.t("errors.messages.html_tag", tag: tag))
          end
        end
      end
    end
  end
end
