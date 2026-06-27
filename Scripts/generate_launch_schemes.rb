#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates shared Xcode schemes with LID_LAUNCH_PROFILE environment variables.
# Run from repo root: ruby Scripts/generate_launch_schemes.rb

require "fileutils"
require "set"

REPO_ROOT = File.expand_path("..", __dir__)
SCHEMES_DIR = File.join(REPO_ROOT, "Leben in Deutschland.xcodeproj", "xcshareddata", "xcschemes")

BLUEPRINT_ID = "E612E89B2E8299CD00513716"
BUILDABLE_NAME = "Leben in Deutschland.app"
BLUEPRINT_NAME = "Leben in Deutschland"
CONTAINER = "container:Leben in Deutschland.xcodeproj"

FEDERAL_STATES = [
  ["Baden-Württemberg", "state_baden_wuerttemberg"],
  ["Bayern", "state_bayern"],
  ["Berlin", "state_berlin"],
  ["Brandenburg", "state_brandenburg"],
  ["Bremen", "state_bremen"],
  ["Hamburg", "state_hamburg"],
  ["Hessen", "state_hessen"],
  ["Mecklenburg-Vorpommern", "state_mecklenburg_vorpommern"],
  ["Niedersachsen", "state_niedersachsen"],
  ["Nordrhein-Westfalen", "state_nordrhein_westfalen"],
  ["Rheinland-Pfalz", "state_rheinland_pfalz"],
  ["Saarland", "state_saarland"],
  ["Sachsen", "state_sachsen"],
  ["Sachsen-Anhalt", "state_sachsen_anhalt"],
  ["Schleswig-Holstein", "state_schleswig_holstein"],
  ["Thüringen", "state_thueringen"]
].freeze

# [scheme label, app language code, Xcode region] — Pro UI language (excludes DE; see LiD Default)
PRO_LANGUAGES = [
  %w[EN en GB],
  %w[RU ru RU],
  %w[TR tr TR],
  %w[UK uk UA]
].freeze

# [scheme label, app language code, Xcode region] — Free-tier language variants
APP_LANGUAGES = [
  %w[DE de DE],
  %w[EN en GB],
  %w[RU ru RU],
  %w[TR tr TR],
  %w[UK uk UA]
].freeze

def schemes
  list = [
    { name: "LiD Default", profile: "default", language: "de", region: "DE", location: "Berlin, Germany" },
    { name: "LiD Onboarding (Fresh)", profile: "onboarding_fresh" }
  ]

  PRO_LANGUAGES.each do |label, code, region|
    list << {
      name: "LiD Pro #{label}",
      profile: "lang_#{code}",
      language: code,
      region: region
    }
  end

  APP_LANGUAGES.each do |label, code, region|
    list << {
      name: "LiD Free Launch Offer #{label}",
      profile: "launch_offer_#{code}",
      language: code,
      region: region
    }
    list << {
      name: "LiD Free Paywall Limits #{label}",
      profile: "paywall_limits_#{code}",
      language: code,
      region: region
    }
  end

  FEDERAL_STATES.each do |state_name, profile|
    list << {
      name: "LiD State #{state_name}",
      profile: profile,
      language: "de",
      region: "DE",
      location: "#{state_name}, Germany"
    }
  end

  list
end

def xml_escape(value)
  value.to_s
      .gsub("&", "&amp;")
      .gsub("<", "&lt;")
      .gsub(">", "&gt;")
      .gsub("\"", "&quot;")
end

def buildable_reference
  <<~XML
               <BuildableReference
                  BuildableIdentifier = "primary"
                  BlueprintIdentifier = "#{BLUEPRINT_ID}"
                  BuildableName = "#{BUILDABLE_NAME}"
                  BlueprintName = "#{BLUEPRINT_NAME}"
                  ReferencedContainer = "#{CONTAINER}">
               </BuildableReference>
  XML
end

def environment_variables(profile)
  <<~XML
         <EnvironmentVariables>
            <EnvironmentVariable
               key = "LID_LAUNCH_PROFILE"
               value = "#{xml_escape(profile)}"
               isEnabled = "YES">
            </EnvironmentVariable>
         </EnvironmentVariables>
  XML
end

def launch_language_attrs(scheme)
  language = scheme[:language]
  region = scheme[:region]
  attrs = []
  attrs << %(language = "#{xml_escape(language)}") if language
  attrs << %(region = "#{xml_escape(region)}") if region
  attrs.empty? ? "" : "\n      #{attrs.join("\n      ")}"
end

def location_block(scheme)
  return "" unless scheme[:location]

  <<~XML
         <LocationScenarioReference
            identifier = "#{xml_escape(scheme[:location])}"
            referenceType = "1">
         </LocationScenarioReference>
  XML
end

def generate_scheme(scheme)
  <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <Scheme
       LastUpgradeVersion = "2650"
       version = "1.7">
       <BuildAction
          parallelizeBuildables = "YES"
          buildImplicitDependencies = "YES"
          buildArchitectures = "Automatic">
          <BuildActionEntries>
             <BuildActionEntry
                buildForTesting = "YES"
                buildForRunning = "YES"
                buildForProfiling = "YES"
                buildForArchiving = "YES"
                buildForAnalyzing = "YES">
    #{buildable_reference}
             </BuildActionEntry>
          </BuildActionEntries>
       </BuildAction>
       <TestAction
          buildConfiguration = "Debug"
          selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
          selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
          shouldUseLaunchSchemeArgsEnv = "YES"
          shouldAutocreateTestPlan = "YES">
       </TestAction>
       <LaunchAction
          buildConfiguration = "Debug"
          selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
          selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
          launchStyle = "0"
          useCustomWorkingDirectory = "NO"
          ignoresPersistentStateOnLaunch = "NO"
          debugDocumentVersioning = "YES"
          debugServiceExtension = "internal"
          allowLocationSimulation = "YES"
          queueDebuggingEnableBacktraceRecording = "Yes"#{launch_language_attrs(scheme)}>
          <BuildableProductRunnable
             runnableDebuggingMode = "0">
    #{buildable_reference}
          </BuildableProductRunnable>
    #{environment_variables(scheme[:profile])}#{location_block(scheme)}
       </LaunchAction>
       <ProfileAction
          buildConfiguration = "Release"
          shouldUseLaunchSchemeArgsEnv = "YES"
          savedToolIdentifier = ""
          useCustomWorkingDirectory = "NO"
          debugDocumentVersioning = "YES">
          <BuildableProductRunnable
             runnableDebuggingMode = "0">
    #{buildable_reference}
          </BuildableProductRunnable>
       </ProfileAction>
       <AnalyzeAction
          buildConfiguration = "Debug">
       </AnalyzeAction>
       <ArchiveAction
          buildConfiguration = "Release"
          revealArchiveInOrganizer = "YES">
       </ArchiveAction>
    </Scheme>
  XML
end

FileUtils.mkdir_p(SCHEMES_DIR)

generated_paths = []
schemes.each do |scheme|
  filename = "#{scheme[:name]}.xcscheme"
  path = File.join(SCHEMES_DIR, filename)
  File.write(path, generate_scheme(scheme))
  generated_paths << path
  puts "Wrote #{filename}"
end

generated_filenames = generated_paths.map { |path| File.basename(path) }.to_set
Dir.glob(File.join(SCHEMES_DIR, "*.xcscheme")).each do |path|
  basename = File.basename(path)
  next if generated_filenames.include?(basename)

  File.delete(path)
  puts "Removed orphaned #{basename}"
end

puts "\nGenerated #{generated_paths.length} schemes in #{SCHEMES_DIR}"
