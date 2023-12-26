echo "请输入公司名称:"
read COMPANY_NAME
REPO_OWNER="arextest"
REPO_NAME="releases"
AREX="arex"
if [[ "$OSTYPE" == "darwin"* ]];then
INSTALL_DIR="/Applications/$AREX"
APP_DATA_FILE="$HOME/Library/Application Support/$AREX"
EXTENSION=".dmg"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]];then
INSTALL_DIR="$ProgramFiles/$AREX"
APP_DATA_FILE="$HOME/AppData/Roaming/$AREX"
EXTENSION=".exe"
else
echo "不支持的操作系统类型。"
exit 1
fi
AREX_INSTALLER="arex_installer$EXTENSION"
RELEASE_INFO=$(curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest")
LATEST_VERSION=$(echo "$RELEASE_INFO"|grep '"tag_name":'|awk -F '"' '{print $4}')
DOWNLOAD_URL=$(echo "$RELEASE_INFO"|grep "browser_download_url.*$EXTENSION"|grep -v "$EXTENSION\.blockmap"|cut -d : -f 2,3|tr -d \")
if [ -z "$DOWNLOAD_URL" ];then
echo "无法获取最新release的安装文件下载链接，请稍后再试。"
exit 1
fi
echo "检测到最新的版本号为: $LATEST_VERSION"
echo "正在下载最新的安装文件..."
curl -L -o $AREX_INSTALLER $DOWNLOAD_URL
if [[ "$OSTYPE" == "darwin"* ]];then
echo "挂载dmg文件并安装应用程序..."
MOUNT_POINT=$(hdiutil attach $AREX_INSTALLER|grep -o "/Volumes/.*")
APP_NAME=$(ls "$MOUNT_POINT"|grep ".app$")
if [ -z "$APP_NAME" ];then
echo "未找到应用程序。请检查dmg文件的内容。"
exit 1
fi
cp -R "$MOUNT_POINT/$APP_NAME" "$INSTALL_DIR"
hdiutil detach "$MOUNT_POINT"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]];then
./$AREX_INSTALLER
else
echo "不支持的操作系统类型。"
exit 1
fi
if [ ! -d "$APP_DATA_FILE" ];then
mkdir -p "$APP_DATA_FILE"
fi
echo "{}" >"$APP_DATA_FILE/config.json"
echo "{
\"companyName\": \"$COMPANY_NAME\"
}" >"$APP_DATA_FILE/config.json"
echo "安装完成！"
