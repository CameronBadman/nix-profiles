{
  description = "Profile development environment installer utility";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      # Utility function to install profiles (system-agnostic)
      installProfiles = system: profiles: 
        let
          pkgs = nixpkgs.legacyPackages.${system};
          
          # Fetch and cache each profile flake
          cachedFlakes = map (profile: {
            inherit (profile) name alias icon;
            registry = profile.registry;
            flake = builtins.getFlake profile.registry;
          }) profiles;
          
          # Create a simple derivation that references all flakes to ensure caching
          installer = pkgs.runCommand "profile-installer" {} ''
            mkdir -p $out
            echo "Profiles cached successfully:" > $out/result.txt
            ${pkgs.lib.concatMapStringsSep "\n" (p: ''
              echo "  ${p.name} (${p.alias}) ${p.icon} - ${p.registry}" >> $out/result.txt
            '') cachedFlakes}
          '';
          
      in {
        inherit cachedFlakes;
        result = installer;
      };
      
    in
    {
      # Export lib at top level
      lib = {
        inherit installProfiles;
      };
    } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
      in {
        # Just provide packages for the per-system structure
        packages = {};
      });
}
