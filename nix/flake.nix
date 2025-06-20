{
  description = "A flake template for Phoenix 1.7 projects.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
  # build for each default system of flake-utils: ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"]
    utils.lib.eachDefaultSystem (
      system: let
        # Declare pkgs for the specific target system we're building for.
        pkgs = import nixpkgs {inherit system;};
        # Declare BEAM version we want to use. If not, defaults to the latest on this channel.
        beamPackages = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang_27;
        # Declare the Elixir version you want to use. If not, defaults to the latest on this channel.
        elixir = beamPackages.elixir_1_18;
        # Explicitly include elixir-ls from the same beam packages
        elixir_ls = beamPackages.elixir-ls;
        # Import a development shell we'll declare in `shell.nix`.
        devShell = import ./shell.nix {inherit pkgs beamPackages;};
      in {
        devShells.default = self.devShells.${system}.dev;
        devShells = {
          dev = import ./shell.nix {
            inherit pkgs beamPackages elixir elixir_ls;
            mixEnv = "dev";
          };
          test = import ./shell.nix {
            inherit pkgs beamPackages elixir elixir_ls;
            mixEnv = "test";
          };
        };
      }
    );
}
