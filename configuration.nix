# Welcome!
# This is my first NixOS config and I have no idea what I'm doing!
# Still on early stages, and pretty sure this will grow a lot during my time on Nix.

# TODO: More Flakes-based configuration.
# TODO: Maybe I should start using home-manager?


{ config, pkgs, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix 
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
     enable = true; 
     version = 2;
     device = "/dev/sda";
  };

  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";

  swapDevices = [ { device = "/swapfile"; size = 2048; } ]; # Set up a swap file
	
  networking = {
     hostName = "hayasaka"; # cute anime girl name
     networkmanager.enable = true;
     networking.nameservers = [ "1.1.1.1" "1.0.0.1" ]; # Use Cloudflare DNS.
     useDHCP = false;
     interfaces.enp0s3.useDHCP = true;
  };
 
  time.timeZone = "America/Bahia";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
     font = "Lat2-Terminus16";
     keyMap = "us";
   };

  # Enable the X11 windowing system.
  services.xserver = {
     enable = true;
     displayManager.sddm.enable = true;
     desktopManager.plasma5.enable = true;
     layout = "br";
     libinput.enable = true;
  };

  # Enable CUPS to print documents. (i'll keep this here, since maybe i'll need to enable it later)
  # services.printing.enable = true;

  # Enable sound.
  # TODO: Switch to Pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Main user account.
  users.users.sazz = {
     defaultUserShell = pkgs.fish;
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
   };

  # Enable the unstable channel.
  # TODO: Use overlays (since I think it's supposed to replace packageOverrides?)
  nixpkgs.config = {
    packageOverrides = pkgs: {
        unstable = import unstableTarball {
          config = config.nixpkgs.config;
      };
    };
    allowUnfree = true;
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    firefox
    fish
    starship
    discord
    neofetch # duh
    htop    

    # KDE Stuff
    latte-dock
    unstable.lightly-qt 
    unstable.libsForQt5.qtstyleplugin-kvantum    
    libsForQt5.ark

    # Fonts
    inter
    fira-code

    # Development tools
    unstable.vscode
    git
    nodejs-17_x
    unstable.insomnia
  ];
  
  # Required to connect Github with VSCode
  services.gnome.gnome-keyring.enable = true;

  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # maybe this is useful? idk
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
