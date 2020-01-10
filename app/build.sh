#!/bin/bash
if [[ $1 == "--help" ]]
then
    echo "Usage: ./build.sh --[run|build|switch] --[local|staging|production]"
    exit 1
fi

gituser=$(git config user.name)
githash=$(git log --pretty=format:'%h' -n 1)
current_time=$(date "+%Y.%m.%d-%H.%M.%S")

if [[ $2 == "--local" ]]
then
    cp android/app/src/main/AndroidManifest_local android/app/src/main/AndroidManifest.xml
    cp android/app/src/main/java/org/jimber/threebotlogin/MainActivity_local android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
    cp android/app/build_local android/app/build.gradle
    cp lib/helpers/EnvConfig_local.dart lib/helpers/EnvConfig.dart

    cp android/app/src/main/res/mipmap-hdpi/ic_launcher_local.png android/app/src/main/res/mipmap-hdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-mdpi/ic_launcher_local.png android/app/src/main/res/mipmap-mdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xhdpi/ic_launcher_local.png android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xxhdpi/ic_launcher_local.png android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_local.png android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

    if [[ $1 == "--run" ]]
    then
        echo "[Local]: Running."
        flutter run -t lib/main.dart
    elif [[ $1 == "--switch" ]]
    then
        echo "[Local]: Switched configs."
    else
        echo "[Local]: Building apk."

        sed -i -e "s/githashvalue/$githash/g" lib/helpers/EnvConfig.dart
        sed -i -e "s/timevalue/$current_time/g" lib/helpers/EnvConfig.dart

        flutter build apk -t lib/main.dart --release
        
        md5hash=$(md5sum build/app/outputs/apk/release/app-release.apk | cut -f 1 -d " ")
        size=$(stat -c '%s' build/app/outputs/apk/release/app-release.apk)
        mv build/app/outputs/apk/release/app-release.apk "build/app/outputs/apk/release/$githash-3BotConnect-Local-$current_time.apk"
        curl -s -X POST "https://api.telegram.org/bot868129294:AAGLGOySYvJJxvIcMHY3XHFaPEPq2MpdGys/sendMessage" -d parse_mode=markdown -d chat_id=-1001186043363 -d parse_mode=markdown -d text="Type: *Local* %0AGit user: *$gituser* %0AGit hash: *$githash* %0ATime: *$current_time* %0ASize: *$size* %0AMD5: *$md5hash*"
        curl -s -X POST "https://api.telegram.org/bot868129294:AAGLGOySYvJJxvIcMHY3XHFaPEPq2MpdGys/sendDocument" -F chat_id=-1001186043363 -F document="@build/app/outputs/apk/release/$githash-3BotConnect-Local-$current_time.apk"
        paplay /usr/share/sounds/gnome/default/alerts/glass.ogg
    fi

    exit 0
fi

if [[ $2 == "--staging" ]]
then
    cp android/app/src/main/AndroidManifest_staging android/app/src/main/AndroidManifest.xml
    cp android/app/src/main/java/org/jimber/threebotlogin/MainActivity_staging android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
    cp android/app/build_staging android/app/build.gradle
    cp lib/helpers/EnvConfig_staging.dart lib/helpers/EnvConfig.dart

    cp android/app/src/main/res/mipmap-hdpi/ic_launcher_staging.png android/app/src/main/res/mipmap-hdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-mdpi/ic_launcher_staging.png android/app/src/main/res/mipmap-mdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xhdpi/ic_launcher_staging.png android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xxhdpi/ic_launcher_staging.png android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_staging.png android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

    if [[ $1 == "--run" ]]
    then
        echo "[Staging]: Running."
        flutter run -t lib/main.dart
    elif [[ $1 == "--switch" ]]
    then
        echo "[Staging]: Switched configs."
    else
        echo "[Staging]: Building apk."

        sed -i -e "s/githashvalue/$githash/g" lib/helpers/EnvConfig.dart
        sed -i -e "s/timevalue/$current_time/g" lib/helpers/EnvConfig.dart

        flutter build apk -t lib/main.dart --release
        
        md5hash=$(md5sum build/app/outputs/apk/release/app-release.apk | cut -f 1 -d " ")
        size=$(stat -c '%s' build/app/outputs/apk/release/app-release.apk)
        mv build/app/outputs/apk/release/app-release.apk "build/app/outputs/apk/release/$githash-3BotConnect-Staging-$current_time.apk"
        curl -s -X POST "https://api.telegram.org/bot868129294:AAGLGOySYvJJxvIcMHY3XHFaPEPq2MpdGys/sendMessage" -d parse_mode=markdown -d chat_id=-1001186043363 -d parse_mode=markdown -d text="Type: *Staging* %0AGit user: *$gituser* %0AGit hash: *$githash* %0ATime: *$current_time* %0ASize: *$size* %0AMD5: *$md5hash*"
        curl -s -X POST "https://api.telegram.org/bot868129294:AAGLGOySYvJJxvIcMHY3XHFaPEPq2MpdGys/sendDocument" -F chat_id=-1001186043363 -F document="@build/app/outputs/apk/release/$githash-3BotConnect-Staging-$current_time.apk"
        paplay /usr/share/sounds/gnome/default/alerts/glass.ogg
    fi

    exit 0
fi

if [[ $2 == "--production" ]]
then
    cp android/app/src/main/AndroidManifest_production android/app/src/main/AndroidManifest.xml
    cp android/app/src/main/java/org/jimber/threebotlogin/MainActivity_production android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
    cp android/app/build_production android/app/build.gradle
    cp lib/helpers/EnvConfig_production.dart lib/helpers/EnvConfig.dart

    cp android/app/src/main/res/mipmap-hdpi/ic_launcher_production.png android/app/src/main/res/mipmap-hdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-mdpi/ic_launcher_production.png android/app/src/main/res/mipmap-mdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xhdpi/ic_launcher_production.png android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xxhdpi/ic_launcher_production.png android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_production.png android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

    if [[ $1 == "--run" ]]
    then
        echo "[Production]: Running."
        flutter run -t lib/main.dart
    elif [[ $1 == "--switch" ]]
    then
        echo "[Production]: Switched configs."
    else
        echo "[Production]: Building apk."

        sed -i -e "s/githashvalue/$githash/g" lib/helpers/EnvConfig.dart
        sed -i -e "s/timevalue/$current_time/g" lib/helpers/EnvConfig.dart

        flutter build apk -t lib/main.dart --release
        
        md5hash=$(md5sum build/app/outputs/apk/release/app-release.apk | cut -f 1 -d " ")
        size=$(stat -c '%s' build/app/outputs/apk/release/app-release.apk)
        mv build/app/outputs/apk/release/app-release.apk "build/app/outputs/apk/release/$githash-3BotConnect-Production-$current_time.apk"
        curl -s -X POST "https://api.telegram.org/bot868129294:AAGLGOySYvJJxvIcMHY3XHFaPEPq2MpdGys/sendMessage" -d parse_mode=markdown -d chat_id=-1001186043363 -d parse_mode=markdown -d text="Type: *Production* %0AGit user: *$gituser* %0AGit hash: *$githash* %0ATime: *$current_time* %0ASize: *$size* %0AMD5: *$md5hash*"
        curl -s -X POST "https://api.telegram.org/bot868129294:AAGLGOySYvJJxvIcMHY3XHFaPEPq2MpdGys/sendDocument" -F chat_id=-1001186043363 -F document="@build/app/outputs/apk/release/$githash-3BotConnect-Production-$current_time.apk"
        paplay /usr/share/sounds/gnome/default/alerts/glass.ogg
    fi

    exit 0
fi

echo "Syntax error."
echo "Usage: ./build.sh --[[run|build|switch]] --[[local|staging|production]]"
exit 1
