{ sources ? import ./nix/sources.nix
, nixpkgs ? sources.nixpkgs
, toolbox ? sources.toolbox
, pkgs ? import nixpkgs {}
, tbox ? import toolbox {}
}:

with pkgs;
with pkgs.lib;

stdenv.mkDerivation rec {
  pname = "os";
  version = "1.1.0";

  unpackPhase = ":";

  buildInputs = [ makeWrapper ];

  installPhase = ''
    install -m755 -D ${./os} $out/bin/os
    wrapProgram $out/bin/os --prefix PATH ":" ${with tbox; makeBinPath [ openstackclient vault curl jq ]}
  '';

  meta = with stdenv.lib; {
    description = "Wrapper around openstack";
    homepage = "https://github.com/Caascad/os";
    license = licenses.mit;
    maintainers = with maintainers; [ "Benjile" ];
  };

}
