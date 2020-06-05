{ sources ? import ./nix/sources.nix
, nixpkgs ? sources.nixpkgs
, pkgs ? import nixpkgs {}
}:

with pkgs;

stdenv.mkDerivation rec {
  pname = "caos";
  version = "1.0.0";

  unpackPhase = ":";
  installPhase = ''
    install -m755 -D ${./caos} $out/bin/caos
  '';

  meta = with stdenv.lib; {
    description = "Wrapper around openstack";
    homepage = "https://github.com/Caascad/caos";
    license = licenses.mit;
    maintainers = with maintainers; [ "Benjile" ];
  };

}
