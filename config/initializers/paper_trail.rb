# frozen_string_literal: true

require 'active_support/time'

if defined?(PaperTrail::Serializers::YAML)
  PaperTrail.serializer = PaperTrail::Serializers::YAML

  module SafeYamlWithTimeWithZone
    def load(yaml)
      return unless yaml

      YAML.safe_load(
        yaml,
        permitted_classes: [
          Time,
          Date,
          Symbol,
          ActiveSupport::TimeWithZone,
          ActiveSupport::TimeZone
        ],
        aliases: true
      )
    end
  end

  PaperTrail::Serializers::YAML.singleton_class.prepend(SafeYamlWithTimeWithZone)
end
