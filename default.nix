{ sources ? import ./nix/sources.nix
, nixpkgs ? sources.nixpkgs
, pkgs ? import nixpkgs {}
}:

with pkgs;

stdenv.mkDerivation rec {
  pname = "os";
  version = "1.0.0";

  unpackPhase = ":";
  installPhase = ''
    install -m755 -D ${./os} $out/bin/os
  '';

  meta = with stdenv.lib; {
    description = "Wrapper around openstack";
    homepage = "https://github.com/Caascad/os";
    license = licenses.mit;
    maintainers = with maintainers; [ "Benjile" ];
  };

}
