# HyDE 安全自定义安装指南

## 项目简介

HyDE (HyprDots Evolution) 是基于 Hyprland Wayland 窗口管理器的完整桌面环境配置套件。它提供了现代化的 Linux 桌面体验，支持多种主题和高度可定制化。

## 核心特性

- 🎨 **丰富的主题系统**：12+ 官方主题，支持自定义主题
- 🖥️ **现代化界面**：基于 Wayland 的流畅体验
- 🔧 **模块化配置**：每个组件都可以独立配置
- 📦 **智能包管理**：自动处理依赖关系
- 🛡️ **配置保护**：备份和恢复功能
- 🎯 **XDG 标准**：遵循 Linux 标准目录规范

## 保护现有配置的安装方法

### 1. 安全安装脚本

我为您创建了安全安装脚本 `install_safe.sh`，它会：

- ✅ 保留您现有的 GRUB 配置
- ✅ 保留您现有的 Shell 配置（.zshrc, .bashrc 等）
- ✅ 备份所有被修改的配置到 `~/.config/cfg_backups`
- ✅ 使用 `P`（Preserve）标志避免覆盖现有配置
- ✅ 仅安装 HyDE 特定的功能和主题

使用方法：
```bash
cd ~/HyDE/Scripts
./install_safe.sh
```

### 2. 配置文件说明

#### 原始配置文件 vs 安全配置文件

| 文件 | 原始行为 | 安全行为 | 说明 |
|------|----------|----------|------|
| `restore_cfg.psv` | 使用 `S`/`O` 标志覆盖配置 | - | 会覆盖现有配置 |
| `restore_cfg_safe.psv` | 使用 `P` 标志保护配置 | ✅ | 保留现有配置 |

#### 标志含义
- `P` (Preserve): 仅在目标不存在时复制，保护现有配置
- `S` (Sync): 同步特定文件，不影响其他配置
- `O` (Overwrite): 完全覆盖（仅用于 HyDE 专用目录）
- `B` (Backup): 自动备份

### 3. 主题管理

使用安全主题管理器：
```bash
# 列出可用主题
./hyde_theme_manager.sh list

# 安装主题
./hyde_theme_manager.sh install Catppuccin-Mocha

# 应用主题（会自动备份当前设置）
./hyde_theme_manager.sh apply Catppuccin-Mocha

# 备份当前主题设置
./hyde_theme_manager.sh backup

# 恢复主题设置
./hyde_theme_manager.sh restore
```

## 自定义化选项

### 1. 配置文件自定义

#### HyDE 核心配置
- `~/.config/hyde/config.toml` - HyDE 主配置文件
- `~/.config/hypr/hyde.conf` - Hyprland HyDE 扩展配置
- `~/.config/hypr/userprefs.conf` - 用户个人配置

#### 用户配置文件（不会被覆盖）
- `~/.config/hypr/hyprland.conf` - 主 Hyprland 配置
- `~/.config/zsh/.zshrc` - ZSH 配置
- `~/.config/kitty/kitty.conf` - 终端配置

### 2. 主题自定义

#### 创建自定义主题
```bash
# 1. 创建主题目录
mkdir -p ~/.config/hyde/themes/MyCustomTheme

# 2. 复制基础主题作为模板
cp -r ~/.config/hyde/themes/Catppuccin-Mocha/* ~/.config/hyde/themes/MyCustomTheme/

# 3. 编辑主题配置
vim ~/.config/hyde/themes/MyCustomTheme/theme.conf
```

#### 主题配置文件结构
```
~/.config/hyde/themes/MyCustomTheme/
├── theme.conf        # 主题配置
├── colors.conf       # 颜色方案
├── wallbash.conf     # 壁纸配色
├── wallpapers/       # 主题壁纸
└── assets/           # 主题资源
```

### 3. 键位绑定自定义

编辑用户键位配置：
```bash
vim ~/.config/hypr/keybindings.conf
```

常用快捷键：
- `Super + Q` - 快速设置
- `Super + A` - 应用启动器
- `Super + T` - 主题选择
- `Super + W` - 壁纸选择
- `Super + Return` - 终端

### 4. 工作流自定义

编辑工作流配置：
```bash
vim ~/.config/hypr/workflows.conf
```

可自定义：
- 窗口规则
- 工作区布局
- 动画效果
- 手势操作

### 5. 组件选择性安装

如果您只想安装特定组件，可以编辑包列表：

```bash
# 复制并自定义包列表
cp Scripts/pkg_core.lst Scripts/pkg_custom.lst

# 编辑自定义包列表
vim Scripts/pkg_custom.lst

# 使用自定义包列表安装
./install.sh pkg_custom.lst
```

## 卸载和恢复

### 完全卸载 HyDE
```bash
cd ~/HyDE/Scripts
./uninstall.sh
```

### 恢复原始配置
```bash
# 从备份恢复配置
cp -r ~/.config/cfg_backups/20241225_120000/* ~/

# 或选择性恢复特定配置
cp ~/.config/cfg_backups/hypr/hyprland.conf ~/.config/hypr/
```

## 更新策略

### 安全更新
```bash
cd ~/HyDE/Scripts
git pull origin master

# 使用安全脚本更新（不会覆盖自定义配置）
./install_safe.sh
```

### 手动选择性更新
```bash
# 仅更新主题
./hyde_theme_manager.sh backup
git pull origin master
./hyde_theme_manager.sh restore

# 仅更新脚本
cp Scripts/*.sh ~/.local/bin/
```

## 故障排除

### 配置冲突
1. 检查备份目录：`ls ~/.config/cfg_backups`
2. 比较配置差异：`diff ~/.config/hypr/hyprland.conf ~/.config/cfg_backups/hypr/hyprland.conf`
3. 选择性恢复：复制需要的配置段落

### 主题问题
1. 重置到默认主题：`./hyde_theme_manager.sh reset`
2. 重新生成配置：`hydectl reload`
3. 检查主题文件：`ls ~/.config/hyde/themes/`

### 服务问题
```bash
# 检查 HyDE 相关服务
systemctl --user status hyde

# 重启服务
systemctl --user restart hyde
```

## 建议的工作流程

1. **首次安装**：使用 `install_safe.sh`
2. **主题测试**：使用 `hyde_theme_manager.sh` 安全地试用主题
3. **配置调整**：编辑用户配置文件进行个性化
4. **定期备份**：使用内置备份功能保存配置
5. **安全更新**：使用安全脚本更新，保护自定义内容

这样您就可以享受 HyDE 的强大功能，同时保护您现有的系统配置！
