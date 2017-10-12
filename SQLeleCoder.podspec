Pod::Spec.new do |s|

    s.name         = "SQLeleCoder"
    s.version      = "0.0.1"
    s.summary      = "Extensions to insert/fetch Codable types in SQLite Databases."

    s.description  = <<-DESC
    SQLeleCoder contains extensions to SQLele that enable you to serialize/
    deserialize Codable types into/from your SQLite database with no extra work.
                   DESC

    s.homepage     = "https://github.com/ahti/SQLeleCoder"

    s.license      = { :type => "MIT", :file => "LICENSE" }

    s.author       = { "Lukas Stabe" => "lukas@stabe.de" }

    s.ios.deployment_target = "10.0"
    s.osx.deployment_target = "10.12"
    s.tvos.deployment_target = "10.0"

    s.source       = { :git => "https://github.com/ahti/SQLeleCoder.git", :tag => "#{s.version}" }

    s.source_files = "Sources/**/*.swift"

    s.test_spec 'Tests' do |test|
        test.source_files  = "Tests/**/*.swift"
        test.exclude_files = "Tests/LinuxMain.swift"
        test.framework     = "XCTest"
    end

end
