AREX="arex"
if [[ "$OSTYPE" == "darwin"* ]];then
APP_DATA_FILE="$HOME/Library/Application Support/$AREX"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]];then
APP_DATA_FILE="$HOME/AppData/Roaming/$AREX"
else
echo "Unsupported operating system type."
exit 1
fi
CONFIG_FILE="$APP_DATA_FILE/config"
if [ ! -f "$CONFIG_FILE" ];then
touch "$CONFIG_FILE"
echo "Configuration file $CONFIG_FILE doesn't exist, created an empty file."
fi
read_config(){
while IFS='=' read -r key value;do
case "$key" in
companyName)COMPANY_NAME="$value"
;;
*)echo "Unknown configuration item: $key"
esac
done <"$CONFIG_FILE"
}
change_company_name(){
read_config
echo "Current company name is: $COMPANY_NAME"
echo "Enter a new company name, or type 'cancel' to cancel the operation:"
read NEW_COMPANY_NAME
if [ "$NEW_COMPANY_NAME" == "cancel" ];then
echo "Operation canceled."
return
fi
COMPANY_NAME="$NEW_COMPANY_NAME"
find "$APP_DATA_FILE" -mindepth 1 ! -name "$CONFIG_FILE" -exec rm -rf {} +
echo "companyName=$COMPANY_NAME" >"$CONFIG_FILE"
echo "Company name updated to: $COMPANY_NAME"
echo ""
}
display_menu(){
echo "====================="
echo "  Configuration Menu "
echo "====================="
echo "1. Change company name"
echo "e. Exit"
echo "====================="
echo "Enter your choice:"
}
while true;do
display_menu
read choice
case $choice in
1)change_company_name
;;
e|E)echo "Exiting..."
exit 0
;;
*)echo "Invalid choice. Please try again."
esac
done
