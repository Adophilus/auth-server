{
  description = "My gleam implementation of an auth server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-24.05";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    devShells.${system} = {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          air
          sqlx-cli
          mitmproxy
          gleam
          erlang
          rebar3
        ];
      };
    };
  };
}
