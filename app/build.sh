#!/bin/bash
shouldBuild=0

if [[ $1 == "--help" ]]
then
    echo "Usage: ./build.sh --[run|build|switch] --[local|staging|production]"
    exit 1
fi

if [[ $2 == "--local" ]]
then
    sed -i -e 's/Environment enviroment = Environment.Staging;/Environment enviroment = Environment.Local;/g' lib/helpers/EnvConfig.dart
    sed -i -e 's/Environment enviroment = Environment.Production;/Environment enviroment = Environment.Local;/g' lib/helpers/EnvConfig.dart

    if grep -q "3Bot Staging" "android/app/src/main/AndroidManifest.xml";
    then
        sed -i -e 's/android:label="3Bot Staging"/android:label="3Bot Local"/g' android/app/src/main/AndroidManifest.xml
    fi

    if grep -q "3Bot Connect" "android/app/src/main/AndroidManifest.xml";
    then
        sed -i -e 's/android:label="3Bot Connect"/android:label="3Bot Staging"/g' android/app/src/main/AndroidManifest.xml
    fi

    if [[ $1 == "--run" ]]
    then
        echo "[Local]: Running."
        flutter run -t lib/main.dart
    elif [[ $1 == "--switch" ]]
    then
        echo "[Local]: Switched configs."
    else
        echo "[Local]: Building apk."

        githash=$(git log --pretty=format:'%h' -n 1)
        current_time=$(date "+%Y.%m.%d-%H.%M.%S")

        sed -i -e "s/githashvalue/$githash/g" lib/helpers/EnvConfig.dart
        sed -i -e "s/timevalue/$current_time/g" lib/helpers/EnvConfig.dart

        flutter build apk -t lib/main.dart
        
        md5hash=$(md5sum build/app/outputs/apk/release/app-release.apk | cut -f 1 -d " ")
        size=$(stat -c '%s' build/app/outputs/apk/release/app-release.apk)
        mv build/app/outputs/apk/release/app-release.apk "build/app/outputs/apk/release/$githash-3BotConnect-Local-$current_time.apk"
        curl -s -X POST "https://api.telegram.org/bot868129294:AAGLGOySYvJJxvIcMHY3XHFaPEPq2MpdGys/sendMessage" -d parse_mode=markdown -d chat_id=-1001186043363 -d parse_mode=markdown -d text="Type: *Local* %0AGit hash: *$githash* %0ATime: *$current_time* %0ASize: *$size* %0AMD5: *$md5hash*"
        curl -s -X POST "https://api.telegram.org/bot868129294:AAGLGOySYvJJxvIcMHY3XHFaPEPq2MpdGys/sendDocument" -F chat_id=-1001186043363 -F document="@build/app/outputs/apk/release/$githash-3BotConnect-Local-$current_time.apk"
        paplay /usr/share/sounds/gnome/default/alerts/glass.ogg
    fi

    exit 0
fi

if [[ $2 == "--staging" ]]
then
    sed -i -e 's/Environment enviroment = Environment.Local;/Environment enviroment = Environment.Staging;/g' lib/helpers/EnvConfig.dart
    sed -i -e 's/Environment enviroment = Environment.Production;/Environment enviroment = Environment.Staging;/g' lib/helpers/EnvConfig.dart

    if grep -q "3Bot Local" "android/app/src/main/AndroidManifest.xml";
    then
        sed -i -e 's/android:label="3Bot Local"/android:label="3Bot Staging"/g' android/app/src/main/AndroidManifest.xml
    fi

    if grep -q "3Bot Connect" "android/app/src/main/AndroidManifest.xml";
    then
        sed -i -e 's/android:label="3Bot Connect"/android:label="3Bot Staging"/g' android/app/src/main/AndroidManifest.xml
    fi

    if [[ $1 == "--run" ]]
    then
        echo "[Staging]: Running."
        flutter run -t lib/main.dart --release
    elif [[ $1 == "--switch" ]]
    then
        echo "[Staging]: Switched configs."
    else
        echo "[Staging]: Building apk."

        githash=$(git log --pretty=format:'%h' -n 1)
        current_time=$(date "+%Y.%m.%d-%H.%M.%S")

        sed -i -e "s/githashvalue/$githash/g" lib/helpers/EnvConfig.dart
        sed -i -e "s/timevalue/$current_time/g" lib/helpers/EnvConfig.dart

        flutter build apk -t lib/main.dart
        
        md5hash=$(md5sum build/app/outputs/apk/release/app-release.apk | cut -f 1 -d " ")
        size=$(stat -c '%s' build/app/outputs/apk/release/app-release.apk)
        mv build/app/outputs/apk/release/app-release.apk "build/app/outputs/apk/release/$githash-3BotConnect-Staging-$current_time.apk"
        curl -s -X POST "https://api.telegram.org/bot868129294:AAGLGOySYvJJxvIcMHY3XHFaPEPq2MpdGys/sendMessage" -d parse_mode=markdown -d chat_id=-1001186043363 -d parse_mode=markdown -d text="Type: *Staging* %0AGit hash: *$githash* %0ATime: *$current_time* %0ASize: *$size* %0AMD5: *$md5hash*"
        curl -s -X POST "https://api.telegram.org/bot868129294:AAGLGOySYvJJxvIcMHY3XHFaPEPq2MpdGys/sendDocument" -F chat_id=-1001186043363 -F document="@build/app/outputs/apk/release/$githash-3BotConnect-Staging-$current_time.apk"
        paplay /usr/share/sounds/gnome/default/alerts/glass.ogg
    fi

    exit 0
fi

if [[ $2 == "--production" ]]
then
    sed -i -e 's/Environment enviroment = Environment.Local;/Environment enviroment = Environment.Production;/g' lib/helpers/EnvConfig.dart
    sed -i -e 's/Environment enviroment = Environment.Staging;/Environment enviroment = Environment.Production;/g' lib/helpers/EnvConfig.dart

    if grep -q "3Bot Local" "android/app/src/main/AndroidManifest.xml";
    then
        sed -i -e 's/android:label="3Bot Local"/android:label="3Bot Connect"/g' android/app/src/main/AndroidManifest.xml
    fi

    if grep -q "3Bot Staging" "android/app/src/main/AndroidManifest.xml";
    then
        sed -i -e 's/android:label="3Bot Staging"/android:label="3Bot Connect"/g' android/app/src/main/AndroidManifest.xml
    fi

    if [[ $1 == "--run" ]]
    then
        echo "[Production]: Running."

        flutter run -t lib/main.dart --release
    elif [[ $1 == "--switch" ]]
    then
        echo "[Production]: Switched configs."
    else
        echo "[Production]: Building apk."

        githash=$(git log --pretty=format:'%h' -n 1)
        current_time=$(date "+%Y.%m.%d-%H.%M.%S")

        sed -i -e "s/githashvalue/$githash/g" lib/helpers/EnvConfig.dart
        sed -i -e "s/timevalue/$current_time/g" lib/helpers/EnvConfig.dart

        flutter build apk -t lib/main.dart
        
        md5hash=$(md5sum build/app/outputs/apk/release/app-release.apk | cut -f 1 -d " ")
        size=$(stat -c '%s' build/app/outputs/apk/release/app-release.apk)
        mv build/app/outputs/apk/release/app-release.apk "build/app/outputs/apk/release/$githash-3BotConnect-Production-$current_time.apk"
        curl -s -X POST "https://api.telegram.org/bot868129294:AAGLGOySYvJJxvIcMHY3XHFaPEPq2MpdGys/sendMessage" -d parse_mode=markdown -d chat_id=-1001186043363 -d parse_mode=markdown -d text="Type: *Production* %0AGit hash: *$githash* %0ATime: *$current_time* %0ASize: *$size* %0AMD5: *$md5hash*"
        curl -s -X POST "https://api.telegram.org/bot868129294:AAGLGOySYvJJxvIcMHY3XHFaPEPq2MpdGys/sendDocument" -F chat_id=-1001186043363 -F document="@build/app/outputs/apk/release/$githash-3BotConnect-Production-$current_time.apk"
        paplay /usr/share/sounds/gnome/default/alerts/glass.ogg
    fi

    exit 0
fi

echo "Syntax error."
echo "Usage: ./build.sh --[[run|build|switch]] --[[local|staging|production]]"
exit 1