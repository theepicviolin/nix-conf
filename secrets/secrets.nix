let
  aditya-nn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINUcl7cT1diqdYv18XR+8yalmKyGmAKs+pPTdluc2Vru aditya@numerical-nexus";
  aditya-hh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEApT3FGE82pvYdOtbsiIbv25wCsjpnuyldBlcVhSgn+ aditya@harmony-host";
  users = [
    aditya-nn
    aditya-hh
  ];

  system-nn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmRoOr8H+fA8AcQSg/XxpU1m5LvU1mqHxGazp0J+tke";
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
  "proton.age".publicKeys = all;
  "borgmatic-nn.age".publicKeys = all;
}
