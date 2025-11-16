{
  description = "Vagrant development environment with VirtualBox 7.2 support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [
            # Patch Vagrant to support VirtualBox 7.2
            (final: prev: {
              vagrant = prev.vagrant.overrideAttrs (old: {
                postPatch = (old.postPatch or "") + ''
                  # Patch meta.rb to support VirtualBox 7.2
                  for file in embedded/gems/gems/vagrant-*/plugins/providers/virtualbox/driver/meta.rb; do
                    if [ -f "$file" ]; then
                      substituteInPlace "$file" \
                        --replace '"7.0", "7.1"' '"7.0", "7.1", "7.2"' \
                        --replace '7\.0|7\.1' '7.0|7.1|7.2'
                    fi
                  done
                '';
              });
            })
          ];
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            vagrant
            virtualbox
          ];

          shellHook = ''
            # Use VBoxManage wrapper to work around NixOS setuid wrapper issues
            WRAPPER_DIR="$(pwd)"
            export PATH="$WRAPPER_DIR:$PATH"
            export VBOX_USER_HOME="$HOME/.config/VirtualBox"

            # Ensure wrapper script exists and is executable
            if [ -f "$WRAPPER_DIR/vboxmanage-wrapper.sh" ]; then
              chmod +x "$WRAPPER_DIR/vboxmanage-wrapper.sh"
              ln -sf vboxmanage-wrapper.sh "$WRAPPER_DIR/VBoxManage" 2>/dev/null || true
            fi

            echo "Vagrant development environment activated!"
            echo "Vagrant version: $(vagrant --version)"
            echo "VirtualBox version: $(/run/current-system/sw/bin/VBoxManage --version)"
            echo ""
            echo "VirtualBox 7.2 support patched into Vagrant"
            echo "PATH configured to use VBoxManage wrapper: $WRAPPER_DIR"
            echo ""
            echo "Start your VM with:"
            echo "  vagrant up --provider=virtualbox"
          '';
        };

        devShells.default = self.devShell.${system};
      });
}
