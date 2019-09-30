require 'fastlane/action'
require_relative '../helper/set_sonar_properties_helper'

module Fastlane
  module Actions
    module SharedValues
      SET_SONAR_PROPERTIES_INPUT_PATH = :SET_SONAR_PROPERTIES_INPUT_PATH
      SET_SONAR_PROPERTIES_OUTPUT_PATH = :SET_SONAR_PROPERTIES_OUTPUT_PATH
      SONAR_PROPERTIES = :SONAR_PROPERTIES
    end

    class SetSonarPropertiesAction < Action
      def self.run(params)
        unless params
          raise "Missing params".red
        end
        path = "#{params[:input_path]}"
        unless File.file?(path)
          raise "Sonar properties file not found for path: #{path}".red
        end

        sonar_props_raw = params[:sonar_props]
        sonar_props = {}

        if sonar_props_raw.class == String
          sonar_props_raw.split(',').each do |pair|
            key, value = pair.split(/=/)
            sonar_props[key] = value
          end
        else
          sonar_props = params[:sonar_props]
        end

        unless sonar_props.class == Hash
          raise "Input :sonar_props is neither a hash dictionary nor a string with \"a=1,b=2\" format.".red
        end

        loaded_sonar_props = {}
        tmp_lines = []

        File.open(params[:input_path], "r+").read.each_line do |line|
          key, value = line.strip.split(/=/)
          if line.start_with?("#") || !value
            tmp_lines.push(line)
          else
            if sonar_props.member?(key)
              value = sonar_props[key]
              if !line.include?("#")
                line = line.gsub(/(=.+)/, "=#{value}")
              else
                line = line.gsub(/(=([^#].)+)#/, "=#{value}#")
              end
              tmp_lines.push(line)
              sonar_props.delete(key)
            else
              tmp_lines.push(line)
            end
            loaded_sonar_props[key] = value
          end
        end

        result_sonar_props = loaded_sonar_props

        sonar_props.each do |key, value|
          tmp_lines.push("#{key}=#{value}")
          result_sonar_props[key] = value
        end

        File.open(params[:output_path], "w") do |output_file|
          tmp_lines.each do |line|
            output_file.puts(line)
          end
        end

        Actions.lane_context[SharedValues::SET_SONAR_PROPERTIES_INPUT_PATH] = params[:input_path]
        Actions.lane_context[SharedValues::SET_SONAR_PROPERTIES_OUTPUT_PATH] = params[:output_path]
        Actions.lane_context[SharedValues::SONAR_PROPERTIES] = result_sonar_props

        return result_sonar_props
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Load and edit sonar properties file'
      end

      def self.authors
        ["Paldom"]
      end

      def self.output
        [
          ['SET_SONAR_PROPERTIES_INPUT_PATH', 'Path of imported sonar properties file'],
          ['SET_SONAR_PROPERTIES_OUTPUT_PATH', 'Path of exported sonar properties file'],
          ['SONAR_PROPERTIES', 'Loaded sonar properties dictionary']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
        "Dictionary of loaded sonar properties."
      end

      def self.details
        # Optional:
        "Load and edit key and value pairs of sonar-project.properties files"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :input_path,
                                       env_name: "FL_SET_SONAR_PROPERTIES_INPUT_PATH",
                                       description: "File path to use to load sonar properties",
                                       optional: true,
                                       is_string: true,
                                       default_value: "sonar-project.properties"),
          FastlaneCore::ConfigItem.new(key: :output_path,
                                       env_name: "FL_SET_SONAR_PROPERTIES_OUTPUT_PATH",
                                       description: "File path to use to write sonar properties",
                                       optional: true,
                                       is_string: true,
                                       default_value: "sonar-project.properties"),
          FastlaneCore::ConfigItem.new(key: :sonar_props,
                                       env_name: "FL_LOAD_RELEASE_NOTES_SEPARATOR",
                                       description: "Sonar properties dictionary to add or rewrite. E.g. { sonar.host.url: \"http://localhost:9000\" } from code or \"sonar.host.url=http://localhost:9000,sonar.language=swift\" from CLI ",
                                       is_string: false,
                                       default_value: {})
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
