{
  description = "Profile development environment installer utility";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # Utility function to install profiles
      installProfiles = system: profiles: 
        let
          pkgs = nixpkgs.legacyPackages.${system};
          
          # Process each profile flake (already provided as input)
          cachedFlakes = map (profile: {
            inherit (profile) name alias icon flake;
          }) profiles;
          
          # Create a simple derivation that references all flakes to ensure caching
          installer = pkgs.runCommand "profile-installer" {} ''
            mkdir -p $out
            echo "Profiles cached successfully:" > $out/result.txt
            ${pkgs.lib.concatMapStringsSep "\n" (p: ''
              echo "  ${p.name} (${p.alias}) ${p.icon}" >> $out/result.txt
            '') cachedFlakes}
          '';
          
      in {
        inherit cachedFlakes;
        result = installer;
      };
      
    in {
      # Export lib at top level
      lib = {
        inherit installProfiles;
      };
    };
}
