let
  aditya-nn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8u4BKgvNoC0a9mjKOFvP0ez1CUH4BGrf5ua9aEdTev aditya@numerical-nexus";
  aditya-hh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEApT3FGE82pvYdOtbsiIbv25wCsjpnuyldBlcVhSgn+ aditya@harmony-host";
  users = [
    aditya-nn
    aditya-hh
  ];

  system-nn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAeOLhKV8gfax9fByekBbllXMEemke+nybHzN8LbHrAk";
  system-hh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRfhi2V25A+vuydU3NUBt0y14bFTgZLAWKGZ3lGjPN7";
  systems = [
    system-nn
    system-hh
  ];
  nn = [
    system-nn
    aditya-nn
  ];
  hh = [
    system-hh
    aditya-hh
  ];
  all = users ++ systems;
in
{
  "NN-US-UT-47.age".publicKeys = nn;
  "NN-US-UT-139.age".publicKeys = nn;
  "NN-US-UT-182.age".publicKeys = nn;
  "NN-US-WA-206.age".publicKeys = nn;
  "NN-US-WA-216.age".publicKeys = nn;
  "NN-CA-1150.age".publicKeys = nn;
  "syncthing.age".publicKeys = all;
}
