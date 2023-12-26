#!/bin/bash

# 交互式输入公司名称
echo "请输入公司名称:"
read COMPANY_NAME # 公司名称校验

# 定义变量
REPO_OWNER="arextest" # 仓库owner
REPO_NAME="releases"  # 仓库名
AREX="arex"

# 根据操作系统设置适当的安装目录和配置文件路径
if [[ "$OSTYPE" == "darwin"* ]]; then # macOS
	INSTALL_DIR="/Applications/$AREX"
	CONFIG_FILE="$HOME/Library/Application Support/$AREX/config.json"
	EXTENSION=".dmg"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then # Windows
	INSTALL_DIR="$ProgramFiles/$AREX"
	CONFIG_FILE="$HOME/AppData/Roaming/$AREX/config.json"
	EXTENSION=".exe"
else
	echo "不支持的操作系统类型。"
	exit 1
fi

AREX_INSTALLER="arex_installer$EXTENSION"

# 使用GitHub API获取最新release的dmg文件下载链接
RELEASE_INFO=$(curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest")
LATEST_VERSION=$(echo "$RELEASE_INFO" | grep '"tag_name":' | awk -F '"' '{print $4}')
DOWNLOAD_URL=$(echo "$RELEASE_INFO" | grep "browser_download_url.*$EXTENSION" | grep -v "$EXTENSION\.blockmap" | cut -d : -f 2,3 | tr -d \")

if [ -z "$DOWNLOAD_URL" ]; then
	echo "无法获取最新release的安装文件下载链接，请稍后再试。"
	exit 1
fi

# 输出最新release的版本号
echo "检测到最新的版本号为: $LATEST_VERSION"

# 下载最新的dmg文件
echo "正在下载最新的安装文件..."
curl -L -o $AREX_INSTALLER $DOWNLOAD_URL

# 根据操作系统进行安装
if [[ "$OSTYPE" == "darwin"* ]]; then # macOS
	# 挂载dmg文件并获取卷标和应用程序名称
  echo "挂载dmg文件并安装应用程序..."
  MOUNT_POINT=$(hdiutil attach $AREX_INSTALLER | grep -o "/Volumes/.*")

  # 获取应用程序名称
  APP_NAME=$(ls "$MOUNT_POINT" | grep ".app$")
  if [ -z "$APP_NAME" ]; then
  	echo "未找到应用程序。请检查dmg文件的内容。"
  	exit 1
  fi

  # 安装应用程序到指定目录
  cp -R "$MOUNT_POINT/$APP_NAME" "$INSTALL_DIR"

  # 卸载dmg文件
  hdiutil detach "$MOUNT_POINT"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then # Windows
	./$AREX_INSTALLER
else
	echo "不支持的操作系统类型。"
	exit 1
fi

# 创建配置文件
echo "{
\"companyName\": \"$COMPANY_NAME\"
}" >"$CONFIG_FILE"

echo "安装完成！"
