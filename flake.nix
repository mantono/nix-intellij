{
  # The flake description - helps identify what this flake is for
  description = "Kotlin development environment with IntelliJ IDEA Community Edition";

  # Inputs specify external dependencies and their sources
  # Think of this as "where to get packages from"
  inputs = {
    # nixpkgs is the main package repository for Nix
    # We're using the unstable branch for latest packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # flake-utils provides helpful utilities for creating flakes
    # It simplifies writing flakes that work across different systems (x86_64-linux, aarch64-darwin, etc.)
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Outputs define what this flake provides
  # The function receives our inputs as parameters
  outputs = { self, nixpkgs, flake-utils }:
    # This creates outputs for each supported system (Linux, macOS, etc.)
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Import nixpkgs for our specific system
        # This gives us access to all available packages
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Define our Kotlin-specific packages
        # We can customize versions or add overlays here if needed
        kotlinPackages = with pkgs; [
          # Kotlin compiler and runtime
          kotlin
          
          # Gradle - popular build tool for Kotlin projects
          gradle
          
          # Maven - alternative build tool
          maven

          # Tool to control the generation of non-source files from sources
          gnumake
          
          # Amazon's distribution of OpenJDK (version 21 is current LTS)
          corretto21

          # Anti-bikeshedding Kotlin linter with built-in formatter
          ktlint

          # Static code analysis for Kotlin
          detekt
        ];

        # Development tools that are useful for any development environment
        devTools = with pkgs; [
          # Git for version control
          git
          
          # Tree for visualizing directory structure
          tree
          
          # Ripgrep for fast text searching
          ripgrep
          
          # Fd for fast file finding
          fd
        ];

      in
      {
        # Development shell - this is what you get when you run 'nix develop'
        # Think of it as your development environment
        devShells.default = pkgs.mkShell {
          # Packages to include in the development environment
          buildInputs = [
            # IntelliJ IDEA Community Edition
            pkgs.jetbrains.idea-community
          ] ++ kotlinPackages ++ devTools;

          # Environment variables to set when entering the shell
          shellHook = ''
            echo "🚀 Kotlin development environment loaded!"
            echo ""
            echo "Available tools:"
            echo "  - IntelliJ IDEA CE: idea-community"
            echo "  - Kotlin compiler: kotlinc"
            echo "  - Gradle: gradle"
            echo "  - Maven: mvn"
            echo "  - Java: java (OpenJDK 21)"
            echo ""
            echo "To start IntelliJ IDEA, run: idea-community"
            echo ""
            
            # Set JAVA_HOME for tools that need it
            export JAVA_HOME="${pkgs.jetbrains.jdk-no-jcef}/lib/openjdk"
            
            # Add Gradle to PATH if not already there
            export PATH="${pkgs.gradle}/bin:$PATH"
          '';

          # Additional environment variables
          # These persist while you're in the development shell
          env = {
            # Some Gradle configurations
            GRADLE_USER_HOME = ".gradle";
            
            # Kotlin compiler options
            KOTLIN_HOME = "${pkgs.kotlin}";
          };
        };

        # Alternative: You can also define packages directly
        # This allows others to install your tools with 'nix build'
        packages.default = pkgs.buildEnv {
          name = "kotlin-dev-env";
          paths = [ pkgs.jetbrains.idea-community-bin ] ++ kotlinPackages ++ devTools;
        };

        # Apps define executable commands
        # This lets you run 'nix run' to start IntelliJ directly
        apps.default = {
          type = "app";
          program = "${pkgs.jetbrains.idea-community-bin}/bin/idea-community -Dawt.toolkit.name=WLToolkit";
        };
      });
}

