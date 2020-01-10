#!/bin/bash

gituser=$(git config user.name)
githash=$(git log --pretty=format:'%h' -n 1)
logcurrent_time=$(date "+%H:%M:%S %d.%m.%Y")
current_time=$(date "+%H.%M.%S-%d.%m.%Y")

switchConfigs() {
    cp android/app/src/main/AndroidManifest_$1 android/app/src/main/AndroidManifest.xml
    cp android/app/src/main/java/org/jimber/threebotlogin/MainActivity_$1 android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
    cp android/app/build_$1 android/app/build.gradle
    cp lib/helpers/EnvConfig_$1.template lib/helpers/EnvConfig.dart

    cp android/app/src/main/res/mipmap-hdpi/ic_launcher_$1.png android/app/src/main/res/mipmap-hdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-mdpi/ic_launcher_$1.png android/app/src/main/res/mipmap-mdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xhdpi/ic_launcher_$1.png android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xxhdpi/ic_launcher_$1.png android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_$1.png android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
}

setConfigsAndBuild() {
    sed -i -e "s/githashvalue/$githash/g" lib/helpers/EnvConfig.dart
    sed -i -e "s/timevalue/$logcurrent_time/g" lib/helpers/EnvConfig.dart

    flutter build apk -t lib/main.dart --release
}

msgTelegram () {
    mv build/app/outputs/apk/release/app-release.apk "build/app/outputs/apk/release/$githash-3BotConnect-$1-$current_time.apk"
    
    curl -s -X POST "https://api.telegram.org/bot868129294:AAGLGOySYvJJxvIcMHY3XHFaPEPq2MpdGys/sendMessage" -d parse_mode=markdown -d chat_id=-1001186043363 -d parse_mode=markdown -d text="Type: *$1* %0AGit user: *$gituser* %0AGit hash: *$githash* %0ATime: *$logcurrent_time* %0AMessage: *$2*"
    curl -s -X POST "https://api.telegram.org/bot868129294:AAGLGOySYvJJxvIcMHY3XHFaPEPq2MpdGys/sendDocument" -F chat_id=-1001186043363 -F document="@build/app/outputs/apk/release/$githash-3BotConnect-$1-$current_time.apk"
    
    paplay /usr/share/sounds/gnome/default/alerts/glass.ogg
}

generateFile () {
    if ! test -f "$1"; then
        echo "$1 doesn't exist, generating ..."
        cp $2 $1
     else
        echo "$1 already exists."
    fi
}

if [[ $1 == "--help" ]]
then
    echo "Usage: ./build.sh --[run|build|switch] --[local|staging|production]"
    echo "Usage: ./build.sh --init"
    exit 1
fi

if [[ $1 == "--init" ]]
then
    EnvConfigFilePath=lib/helpers/EnvConfig.dart
    AppConfigLocalFilePath=lib/AppConfigLocal.dart

    MainActivityPath=android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
    BuildGradlePath=android/app/build.gradle

    LauncherImgPath1=android/app/src/main/res/mipmap-hdpi/ic_launcher.png
    LauncherImgPath2=android/app/src/main/res/mipmap-mdpi/ic_launcher.png
    LauncherImgPath3=android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
    LauncherImgPath4=android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
    LauncherImgPath5=android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

    generateFile $EnvConfigFilePath lib/helpers/EnvConfig_local.template
    generateFile $AppConfigLocalFilePath lib/AppConfigLocal.template

    generateFile $MainActivityPath android/app/src/main/java/org/jimber/threebotlogin/MainActivity_local
    generateFile $BuildGradlePath android/app/build_local
    
    generateFile $LauncherImgPath1 android/app/src/main/res/mipmap-hdpi/ic_launcher_local.png
    generateFile $LauncherImgPath2 android/app/src/main/res/mipmap-mdpi/ic_launcher_local.png
    generateFile $LauncherImgPath3 android/app/src/main/res/mipmap-xhdpi/ic_launcher_local.png
    generateFile $LauncherImgPath4 android/app/src/main/res/mipmap-xxhdpi/ic_launcher_local.png
    generateFile $LauncherImgPath5 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_local.png

    exit 0
fi

if [[ $2 == "--local" ]]
then
    switchConfigs "local"

    if [[ $1 == "--run" ]]
    then
        echo "[Local]: Running."
        flutter run -t lib/main.dart
    elif [[ $1 == "--switch" ]]
    then
        echo "[Local]: Switched configs."
    else
        echo "[Local]: Building apk."

        setConfigsAndBuild
        msgTelegram "Local" $4
    fi

    exit 0
fi

if [[ $2 == "--staging" ]]
then
    switchConfigs "staging"

    if [[ $1 == "--run" ]]
    then
        echo "[Staging]: Running."
        flutter run -t lib/main.dart
    elif [[ $1 == "--switch" ]]
    then
        echo "[Staging]: Switched configs."
    else
        echo "[Staging]: Building apk."

        setConfigsAndBuild
        msgTelegram "Staging" $4
    fi

    exit 0
fi

if [[ $2 == "--production" ]]
then
    switchConfigs "production"

    if [[ $1 == "--run" ]]
    then
        echo "[Production]: Running."
        flutter run -t lib/main.dart
    elif [[ $1 == "--switch" ]]
    then
        echo "[Production]: Switched configs."
    else
        echo "[Production]: Building apk."

        setConfigsAndBuild
        msgTelegram "Production" $4
    fi

    exit 0
fi

echo "Syntax error."
echo "Usage: ./build.sh --[[run|build|switch]] --[[local|staging|production]]"
echo "Usage: ./build.sh --init"
exit 1
