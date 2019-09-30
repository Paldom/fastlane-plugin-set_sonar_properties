require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class SetSonarPropertiesHelper
      # class methods that you define here become available in your action
      # as `Helper::SetSonarPropertiesHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the set_sonar_properties plugin helper!")
      end
    end
  end
end
