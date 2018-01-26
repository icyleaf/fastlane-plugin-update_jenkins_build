require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class UpdateJenkinsBuildHelper
      # class methods that you define here become available in your action
      # as `Helper::UpdateJenkinsBuildHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the update_jenkins_build plugin helper!")
      end
    end
  end
end
