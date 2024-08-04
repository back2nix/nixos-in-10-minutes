{
  modulesPath,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.vim
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/Pm3dni/sg8gvQrO8nZGCYLxlPMwO3RfY92msE3zICVyu0ycCUIiRB1KW4JSOdkwglt2wbrhQcb1FdUKAnNNybp78abA8NXUcM5oSDrq4ZVyKTm/qKENpLg7ajni8BXwV3fr0p55nKc+sfl1/Pqcl0X8yHXm4Nr18z9kwy70yS4+F+6rHaVnOfcE+/2ms8q0eG/hxYuTqt47BMfaD5UqFB0MfS7147GqnHfJfzuUn0TMueFvE9V/zZS/0Ner/Pi/5iz+g8AASRkZQvNhCjWXOqCOSqhkrvo3a9M5V03+1CJ4tefhdHt/HvrHbUaxb6HkD8vqbU6P6p01BrzB6F4awq9VeJ9SfrEEZaLWbtg1nn0NBjdNlMaimaP7uSF2HL4K+V4qbfFV58SXbs1EyHwH0nsWVrgtmPK7KrAUgWyBG2AnGAkrTvUEb465KVNa4YQp9FKD8uy3kkpXIzdumXhWLwKayssEPri2kg36uTFkEjq8jTIeltjyueTK8KuSFfAJ//emBqrZC1FKnwXR+uQ1FB7dfUDKCkhXUpdBLHT1DOrkofMoOFDETP9gJghTza+sfEMU/lQSOnMBsn5aAGKs+62EsM2kTfq0JRicPOyX7m5TlH6Rv7qWSYYy0or7CqVf/rZqS0NC6KILWDo9H3T3ZZ7/EHGrAsHnzhjbFsD+PhQ== bg@nixos"
  ];

  system.stateVersion = "23.11";
}
