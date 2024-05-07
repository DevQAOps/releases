COMPANY_NAME=""
while getopts "c:" opt;do
case $opt in
c)COMPANY_NAME="$OPTARG";;
*)echo "Invalid parameter" >&2
exit 1
esac
done
if [ -z "$COMPANY_NAME" ];then
echo "Please enter the company name:"
read COMPANY_NAME
fi
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
echo "Unsupported operating system type."
exit 1
fi
AREX_INSTALLER="arex_installer$EXTENSION"
AREX_DATA_FILE="$APP_DATA_FILE/data.json"
AREX_CONFIG_FILE="$APP_DATA_FILE/config"
RELEASE_INFO=$(curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest")
LATEST_VERSION=$(echo "$RELEASE_INFO"|grep '"tag_name":'|awk -F '"' '{print $4}')
DOWNLOAD_URL=$(echo "$RELEASE_INFO"|grep "browser_download_url.*$EXTENSION"|grep -v "$EXTENSION\.blockmap"|cut -d : -f 2,3|tr -d \")
if [ -z "$DOWNLOAD_URL" ];then
echo "Failed to fetch the installation file download link for the latest release. Please try again later."
exit 1
fi
echo "Detected latest version: $LATEST_VERSION"
echo "Downloading the latest installation file..."
curl -L -o $AREX_INSTALLER $DOWNLOAD_URL
if [[ "$OSTYPE" == "darwin"* ]];then
echo "Mounting the dmg file and installing the application..."
MOUNT_POINT=$(hdiutil attach $AREX_INSTALLER|grep -o "/Volumes/.*")
APP_NAME=$(ls "$MOUNT_POINT"|grep ".app$")
if [ -z "$APP_NAME" ];then
echo "Application not found. Please check the contents of the $EXTENSION file."
exit 1
fi
ditto "$MOUNT_POINT/$APP_NAME" "$INSTALL_DIR/$APP_NAME"
hdiutil detach "$MOUNT_POINT"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]];then
./$AREX_INSTALLER
else
echo "Unsupported operating system type."
exit 1
fi
if [ ! -d "$APP_DATA_FILE" ];then
mkdir -p "$APP_DATA_FILE"
else
rm -rf "$APP_DATA_FILE"/*
fi
echo "{}" >"$AREX_DATA_FILE"
if [ ! -f "$AREX_CONFIG_FILE" ];then
touch "$AREX_CONFIG_FILE"
fi
echo "companyName=$COMPANY_NAME" >"$AREX_CONFIG_FILE"
echo "Installation completed!"
