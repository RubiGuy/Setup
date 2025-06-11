#!/bin/bash

# Hyprland Full Setup Script for Arch Linux
# Inclui: Hyprland + LazyVim (C++) + Temas + Wallpapers + Animações + Plymouth + Dotfiles
# Autor: ChatGPT - GPT-4.5

set -e

# 1. Atualiza o sistema
sudo pacman -Syu --noconfirm

# 2. Instala pacotes essenciais
sudo pacman -S --noconfirm \
  hyprland kitty waybar wofi dunst hyprpaper \
  xdg-desktop-portal-hyprland polkit-kde-agent \
  flameshot cliphist pavucontrol brightnessctl \
  network-manager-applet pipewire pipewire-audio \
  pipewire-pulse wireplumber \
  btop fastfetch ranger zsh neovim git curl unzip ripgrep fd \
  lua-language-server cmake g++ make gcc \
  ttf-jetbrains-mono ttf-font-awesome papirus-icon-theme lxappearance \
  playerctl trash-cli xdg-user-dirs xdg-utils imv gamemode wlogout \
  plymouth

# 3. Configura zsh com Oh My Zsh
echo "Configurando ZSH..."
chsh -s /bin/zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 4. Aliases no ZSH
cat << 'EOF' >> ~/.zshrc
# Aliases pessoais
alias update="sudo pacman -Syu"
alias clean="sudo pacman -Rns $(pacman -Qdtq)"
alias ranger="ranger"
alias n="nvim"
alias open="xdg-open"
EOF

# 5. Instala LazyVim com suporte C++
mkdir -p ~/.config/nvim
cd ~/.config/nvim
rm -rf *
git clone https://github.com/LazyVim/starter .
rm -rf .git

# Adiciona suporte C++ no LazyVim
mkdir -p ~/.config/nvim/lua/plugins
cat << 'EOF' > ~/.config/nvim/lua/plugins/cpp.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {},
      },
    },
  },
}
EOF

# 6. Configura Hyprland (animações, blur, atalhos)
mkdir -p ~/.config/hypr
cat << 'EOF' > ~/.config/hypr/hyprland.conf
exec-once = wl-paste --watch cliphist store &
exec-once = dunst &
exec-once = waybar &
exec-once = hyprpaper &
exec-once = nm-applet &
exec-once = playerctld &
exec-once = gamemoded -r &

# Keybinds
bind = SUPER, RETURN, exec, kitty
bind = SUPER, D, exec, wofi --show drun
bind = SUPER, E, exec, ranger
bind = SUPER, ESCAPE, exec, wlogout

# Animações
animations {
  enabled = yes
  bezier = ease, 0.25, 1, 0.5, 1
  animation = windows, 1, 7, ease
  animation = fade, 1, 6, ease
  animation = workspaces, 1, 6, ease
}

decoration {
  blur {
    enabled = true
    size = 8
    passes = 2
  }
}

input {
  kb_layout = us
}
EOF

# 7. Wallpapers com Hyprpaper
mkdir -p ~/Pictures/Wallpapers
curl -L -o ~/Pictures/Wallpapers/mountain.jpg https://images.unsplash.com/photo-1506744038136-46273834b3fb
cat << 'EOF' > ~/.config/hypr/hyprpaper.conf
preload = ~/Pictures/Wallpapers/mountain.jpg
wallpaper = ,~/Pictures/Wallpapers/mountain.jpg
EOF

# 8. Tema de boot (Plymouth - Proxzima)
cd /opt && sudo git clone https://github.com/adi1090x/plymouth-themes.git
sudo cp -r /opt/plymouth-themes/pack_4/proxzima /usr/share/plymouth/themes/
sudo plymouth-set-default-theme -R proxzima

# 9. Configura GRUB para boot direto no Arch
sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
sudo sed -i 's/^#GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3"/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# 10. Define diretórios padrão
xdg-user-dirs-update

# 11. Auto login Hyprland
if [ -f ~/.bash_profile ]; then
    echo "exec Hyprland" >> ~/.bash_profile
else
    echo "exec Hyprland" > ~/.zprofile
fi

# 12. Finaliza
echo "✅ Ambiente Hyprland completo instalado com sucesso! Reinicie para aplicar tudo."
echo "👉 Use Ctrl + Alt + F2 para trocar para TTY e logar com seu usuário."
echo "✨ Ao logar, o Hyprland será iniciado automaticamente com animações e tema Proxzima no boot."
