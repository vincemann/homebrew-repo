class SubtitleBuddy < Formula
  desc "Opensource Subtitle Player"
  homepage "https://github.com/vincemann/subtitle-buddy"
  download_host = "http://192.168.178.69:8000"
  version="1.1.0"

  if OS.mac?
    if Hardware::CPU.arm?
      url "#{download_host}/subtitle-buddy-#{version}-mac-aarch64-image.zip"
      sha256 "aarch64-specific-sha256-checksum-here"
    else
      url "#{download_host}/subtitle-buddy-#{version}-mac-x64-image.zip"
      sha256 "0142f173d8ed0a051dd53f71c48651bf51694fc03718a99bb1f198715c857fba"
    end
  elsif OS.linux?
    url "#{download_host}/subtitle-buddy-#{version}-linux-image.zip"
    sha256 "6e700024ff9b39744d9c80218840cb52c6058893b829abd58de010c7de0e147e"
  end


  def install
    # Extract the zip file to the libexec directory
    libexec.install Dir["*"]

    # Install the launch script by creating a symlink in Homebrew's bin directory
    bin.install_symlink libexec/"bin/appLauncher" => "subtitle-buddy"
  end

  def post_install
    if OS.mac?
      # URLs to the correct libraries
      download_host = "http://192.168.178.69:8000"
      jnativehook_arm64_url = "#{download_host}/libJNativeHook_arm64.dylib"
      jnativehook_x86_64_url = "#{download_host}/libJNativeHook_x86_64.dylib"
      libjvm_url = "#{download_host}/libjvm.dylib"
      libjsig_url = "#{download_host}/libjsig.dylib"

      # Download and replace the necessary files using curl
      system "curl", "-L", "-o", "#{libexec}/lib/jnativehook/darwin/arm64/libJNativeHook.dylib", jnativehook_arm64_url
      system "curl", "-L", "-o", "#{libexec}/lib/jnativehook/darwin/x86_64/libJNativeHook.dylib", jnativehook_x86_64_url
      system "curl", "-L", "-o", "#{libexec}/lib/server/libjvm.dylib", libjvm_url
      system "curl", "-L", "-o", "#{libexec}/lib/server/libjsig.dylib", libjsig_url

      # Ensure the files have the correct permissions
      chmod 0755, "#{libexec}/lib/jnativehook/darwin/arm64/libJNativeHook.dylib"
      chmod 0755, "#{libexec}/lib/jnativehook/darwin/x86_64/libJNativeHook.dylib"
      chmod 0755, "#{libexec}/lib/server/libjvm.dylib"
      chmod 0755, "#{libexec}/lib/server/libjsig.dylib"
    end
  end

  test do
    # The test block ensures the symlink exists and points to an executable file
    assert_predicate bin/"subtitle-buddy", :executable?, "Subtitle Buddy should be executable"
    
    # Run the version command and check if it returns the correct version
    output = shell_output("#{bin}/subtitle-buddy --version")
    assert_match "Version: #{version}", output.strip, "Version output should match the expected version"
  end
end
