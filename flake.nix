{
  description = "Vagrant development environment with libvirt/QEMU support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            # vagrant from nixpkgs bundles the vagrant-libvirt plugin on Linux,
            # so no `vagrant plugin install` is needed.
            vagrant
            # libvirt client tooling (virsh); the daemon is provided by the
            # NixOS host module (virtualisation.libvirtd.enable).
            libvirt
            qemu
          ];

          shellHook = ''
            # Default to the libvirt provider so `vagrant up` needs no flag.
            export VAGRANT_DEFAULT_PROVIDER=libvirt
            # Talk to the system libvirt daemon, not a per-user session one.
            export LIBVIRT_DEFAULT_URI="qemu:///system"

            echo "Vagrant development environment activated!"
            echo "Vagrant version: $(vagrant --version)"
            echo "libvirt version: $(virsh --version 2>/dev/null || echo 'virsh unavailable')"
            echo ""
            echo "Provider: libvirt ($LIBVIRT_DEFAULT_URI)"
            echo ""
            echo "Start your VM with:"
            echo "  vagrant up"
          '';
        };

        devShells.default = self.devShell.${system};
      });
}
