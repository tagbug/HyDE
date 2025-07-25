#!/usr/bin/env bash
# Custom HyDE installation script that preserves existing configurations
# This script is designed to safely install HyDE without overwriting your existing configs

scrDir="$(dirname "$(realpath "$0")")"
# shellcheck disable=SC1091
if ! source "${scrDir}/global_fn.sh"; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

echo "==================================================================="
echo "              HyDE Safe Installation Script"
echo "==================================================================="
echo "This script will install HyDE while preserving your existing configs"
echo "All your current configurations will be safely backed up"
echo "==================================================================="
echo

# 检查是否存在关键配置文件
echo "Checking existing configurations..."
existing_configs=()

if [ -f "$HOME/.zshrc" ]; then
    existing_configs+=("ZSH configuration")
fi

if [ -f "/etc/default/grub" ]; then
    existing_configs+=("GRUB configuration")
fi

if [ -d "$HOME/.config/hypr" ]; then
    existing_configs+=("Hyprland configuration")
fi

if [ ${#existing_configs[@]} -gt 0 ]; then
    echo "Found existing configurations:"
    for config in "${existing_configs[@]}"; do
        echo "  - $config"
    done
    echo
    echo "These will be preserved and backed up to ~/.config/cfg_backups"
    echo
fi

# 询问用户是否继续
read -p "Continue with safe installation? [Y/n]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ -n $REPLY ]]; then
    echo "Installation cancelled."
    exit 1
fi

# 设置环境变量以使用安全配置文件
export RESTORE_CFG_FILE="${scrDir}/restore_cfg_safe.psv"

# 检查是否跳过 GRUB 配置
skip_grub=false
if [ -f "/etc/default/grub" ]; then
    echo "Existing GRUB configuration detected."
    read -p "Skip GRUB configuration to preserve your current setup? [Y/n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        skip_grub=true
        echo "GRUB configuration will be skipped."
    fi
fi

# 运行安装脚本的各个阶段
echo "Starting HyDE installation..."

# 1. 预安装配置（可选择跳过 GRUB）
if [ "$skip_grub" = true ]; then
    echo "Skipping pre-installation GRUB configuration..."
else
    echo "Running pre-installation configuration..."
    "${scrDir}/install_pre.sh"
fi

# 2. 安装包
echo "Installing packages..."
"${scrDir}/install_pkg.sh"

# 3. 使用安全配置文件恢复配置
echo "Deploying HyDE configurations safely..."
if [ -f "${RESTORE_CFG_FILE}" ]; then
    export RESTORE_CFG_LIST="${RESTORE_CFG_FILE}"
    "${scrDir}/restore_cfg.sh"
else
    echo "Safe configuration file not found, using default with backup..."
    "${scrDir}/restore_cfg.sh"
fi

# 4. 安装后配置
echo "Running post-installation configuration..."
"${scrDir}/install_pst.sh"

echo
echo "==================================================================="
echo "          HyDE Safe Installation Complete!"
echo "==================================================================="
echo "Your original configurations have been backed up to:"
echo "  ~/.config/cfg_backups"
echo
echo "HyDE-specific configurations installed to:"
echo "  ~/.config/hyde/"
echo "  ~/.config/hypr/"
echo
echo "To start using HyDE:"
echo "  1. Reboot your system"
echo "  2. Select Hyprland in your display manager"
echo "  3. Use Super+Q to open the quick settings"
echo "  4. Use Super+A to open the application launcher"
echo
echo "For theming: Run 'hyde theme' or 'hydectl theme'"
echo "For help: Run 'hyde help' or check https://hydeproject.pages.dev/"
echo "==================================================================="
