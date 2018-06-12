require "rails_html_validator/version"
require 'active_model'
require 'active_support/i18n'
require 'nokogumbo'
I18n.load_path += Dir[File.dirname(__FILE__) + "/locale/*.yml"]

module ActiveModel
  module Validations
    class HtmlValidator < ::ActiveModel::EachValidator
      HTML5_TAGS = %w(section nav article aside header footer figure figcaption time mark ruby rt rp wbr embed video audio source canvas datalist optgroup option textarea keygen output progress meter details summary command menu )

      def initialize(options)
        options.reverse_merge!(exclude_tags: [])
        super(options)
      end

      def validate_each(record, attribute, value)
        html = ::Nokogiri.HTML(value) {|config| config.strict}
        errors = ignore_html5_tag_errors(html.errors)
        if errors.present?
          record.errors.add(attribute, I18n.t("errors.messages.html"))
          errors.each do |err|
            record.errors.add(attribute, err.message)
          end
        end

        options.fetch(:exclude_tags).each do |tag|
          if html.css(tag.to_s).present?
            record.errors.add(attribute, I18n.t("errors.messages.html_tag", tag: tag))
          end
        end
      end

      def ignore_html5_tag_errors errors
        checker = HTML5_TAGS.map { |tag| "Tag #{tag} invalid"}
        regexp = Regexp.union()
        errors.select do |error|
          regexp.match(error.message).blank?
        end
      end


    end
  end
end
