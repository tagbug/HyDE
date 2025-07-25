#!/usr/bin/env bash
# HyDE Theme Management Script
# Safely manage themes without affecting core system configurations

scrDir="$(dirname "$(realpath "$0")")"
# shellcheck disable=SC1091
if ! source "${scrDir}/global_fn.sh"; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

HYDE_THEMES_DIR="$HOME/.config/hyde/themes"
HYDE_CONFIG_DIR="$HOME/.config/hyde"

# 确保主题目录存在
mkdir -p "$HYDE_THEMES_DIR"
mkdir -p "$HYDE_CONFIG_DIR"

show_help() {
    cat << EOF
HyDE Theme Manager - Safe Theme Management

Usage: $0 [COMMAND] [OPTIONS]

Commands:
    list            List all available themes
    install THEME   Install a specific theme
    apply THEME     Apply a theme (non-destructive)
    backup          Backup current theme settings
    restore         Restore theme settings from backup
    reset           Reset to default HyDE theme
    help            Show this help message

Examples:
    $0 list                    # List available themes
    $0 install Catppuccin-Mocha # Install Catppuccin Mocha theme
    $0 apply Frosted-Glass     # Apply Frosted Glass theme
    $0 backup                  # Backup current settings
    $0 restore                 # Restore from backup

Theme Installation:
    Themes are installed to ~/.config/hyde/themes/
    Your original configurations remain untouched
    Wallpapers are stored in ~/.local/share/hyde/wallpapers/

EOF
}

list_themes() {
    echo "Available HyDE Themes:"
    echo "====================="
    
    # List official themes
    cat << EOF
Official Themes:
  - Catppuccin-Latte
  - Catppuccin-Mocha  
  - Decay-Green
  - Edge-Runner
  - Frosted-Glass
  - Graphite-Mono
  - Gruvbox-Retro
  - Material-Sakura
  - Nordic-Blue
  - Rosé-Pine
  - Synth-Wave
  - Tokyo-Night

Installed Themes:
EOF
    
    if [ -d "$HYDE_THEMES_DIR" ]; then
        for theme in "$HYDE_THEMES_DIR"/*; do
            if [ -d "$theme" ]; then
                echo "  - $(basename "$theme")"
            fi
        done
    else
        echo "  No themes installed yet"
    fi
}

install_theme() {
    local theme_name="$1"
    
    if [ -z "$theme_name" ]; then
        echo "Error: Please specify a theme name"
        echo "Use '$0 list' to see available themes"
        return 1
    fi
    
    echo "Installing theme: $theme_name"
    echo "This will download the theme to $HYDE_THEMES_DIR/$theme_name"
    
    # 使用 themepatcher 安装主题
    if command -v hyde >/dev/null 2>&1; then
        hyde theme -i "$theme_name"
    else
        echo "Installing theme using git..."
        git clone --depth 1 "https://github.com/HyDE-Project/hyde-themes.git" -b "$theme_name" "$HYDE_THEMES_DIR/$theme_name" 2>/dev/null || {
            echo "Error: Theme '$theme_name' not found or failed to download"
            echo "Please check the theme name and try again"
            return 1
        }
    fi
    
    echo "Theme '$theme_name' installed successfully!"
}

apply_theme() {
    local theme_name="$1"
    
    if [ -z "$theme_name" ]; then
        echo "Error: Please specify a theme name"
        return 1
    fi
    
    if [ ! -d "$HYDE_THEMES_DIR/$theme_name" ]; then
        echo "Error: Theme '$theme_name' is not installed"
        echo "Use '$0 install $theme_name' to install it first"
        return 1
    fi
    
    echo "Applying theme: $theme_name"
    
    # 备份当前主题配置
    backup_theme
    
    # 应用新主题
    if command -v hyde >/dev/null 2>&1; then
        hyde theme -s "$theme_name"
    else
        # 手动应用主题配置
        if [ -f "$HYDE_THEMES_DIR/$theme_name/hyde.conf" ]; then
            cp "$HYDE_THEMES_DIR/$theme_name/hyde.conf" "$HYDE_CONFIG_DIR/"
        fi
        
        # 复制主题相关文件
        if [ -d "$HYDE_THEMES_DIR/$theme_name/.config" ]; then
            cp -r "$HYDE_THEMES_DIR/$theme_name/.config/"* "$HOME/.config/" 2>/dev/null || true
        fi
    fi
    
    echo "Theme '$theme_name' applied successfully!"
    echo "Restart Hyprland to see the changes: hyprctl reload"
}

backup_theme() {
    local backup_dir="$HOME/.config/cfg_backups/hyde_themes/$(date +%Y%m%d_%H%M%S)"
    
    echo "Creating theme backup at: $backup_dir"
    mkdir -p "$backup_dir"
    
    # 备份当前主题配置
    if [ -f "$HOME/.config/hypr/themes/theme.conf" ]; then
        cp "$HOME/.config/hypr/themes/theme.conf" "$backup_dir/"
    fi
    
    if [ -f "$HOME/.config/hypr/themes/colors.conf" ]; then
        cp "$HOME/.config/hypr/themes/colors.conf" "$backup_dir/"
    fi
    
    if [ -f "$HOME/.config/hyde/config.toml" ]; then
        cp "$HOME/.config/hyde/config.toml" "$backup_dir/"
    fi
    
    echo "Theme backup created successfully!"
}

restore_theme() {
    local backup_dir="$HOME/.config/cfg_backups/hyde_themes"
    
    if [ ! -d "$backup_dir" ]; then
        echo "No theme backups found"
        return 1
    fi
    
    echo "Available backups:"
    ls -1 "$backup_dir" | sort -r
    
    read -p "Enter backup date/time to restore (or 'latest' for most recent): " backup_choice
    
    if [ "$backup_choice" = "latest" ]; then
        backup_choice=$(ls -1 "$backup_dir" | sort -r | head -n 1)
    fi
    
    local restore_path="$backup_dir/$backup_choice"
    
    if [ ! -d "$restore_path" ]; then
        echo "Backup '$backup_choice' not found"
        return 1
    fi
    
    echo "Restoring theme from: $restore_path"
    
    # 恢复备份的配置文件
    if [ -f "$restore_path/theme.conf" ]; then
        cp "$restore_path/theme.conf" "$HOME/.config/hypr/themes/"
    fi
    
    if [ -f "$restore_path/colors.conf" ]; then
        cp "$restore_path/colors.conf" "$HOME/.config/hypr/themes/"
    fi
    
    if [ -f "$restore_path/config.toml" ]; then
        cp "$restore_path/config.toml" "$HOME/.config/hyde/"
    fi
    
    echo "Theme restored successfully!"
    echo "Restart Hyprland to see the changes: hyprctl reload"
}

# 主程序逻辑
case "$1" in
    list)
        list_themes
        ;;
    install)
        install_theme "$2"
        ;;
    apply)
        apply_theme "$2"
        ;;
    backup)
        backup_theme
        ;;
    restore)
        restore_theme
        ;;
    reset)
        echo "Resetting to default HyDE theme..."
        if [ -f "$cloneDir/Configs/.config/hypr/themes/theme.conf" ]; then
            cp "$cloneDir/Configs/.config/hypr/themes/theme.conf" "$HOME/.config/hypr/themes/"
        fi
        echo "Reset complete. Restart Hyprland to see changes."
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        ;;
esac
