{
	description = "ZSpace NixOS Configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
	};

	outputs = { self, nixpkgs, ... }: {
		nixosModules = {
			default = ./zspace-config.nix;
			zspace = ./zspace-config.nix;
		};
	};
}