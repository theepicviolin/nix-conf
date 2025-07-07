let
  aditya = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8u4BKgvNoC0a9mjKOFvP0ez1CUH4BGrf5ua9aEdTev aditya@numerical-nexus";
  users = [ aditya ];

  nn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAeOLhKV8gfax9fByekBbllXMEemke+nybHzN8LbHrAk";
  systems = [ nn ];
in
{
  "NN-US-UT-47.age".publicKeys = [
    nn
    aditya
  ];
  "NN-US-UT-139.age".publicKeys = [
    nn
    aditya
  ];
  "NN-US-UT-182.age".publicKeys = [
    nn
    aditya
  ];
  "NN-US-WA-216.age".publicKeys = [
    nn
    aditya
  ];
}
