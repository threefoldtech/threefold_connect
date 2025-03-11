#!/bin/bash

gituser=$(git config user.name)
gitbranch=$(git rev-parse --abbrev-ref HEAD)
githash=$(git log --pretty=format:'%h' -n 1)
logcurrent_time=$(date "+%H:%M:%S %d.%m.%Y")
current_time=$(date "+%Y.%m.%d-%H.%M.%S")

compileAndUpload() {
    if [[ $2 == "--$4" ]]
    then
        switchConfigs "$4"

        if [[ $1 == "--run" ]]
        then
            echo "[$4]: Running."
            flutter run -t lib/main.dart
        elif [[ $1 == "--switch" ]]
        then
            echo "[$4]: Switched configs."
        else
            echo "[$4]: Building apk."

            setConfigsAndBuild "$3"
        fi

        exit 0
    fi
}

switchConfigs() {
    cp android/app/src/main/AndroidManifest_$1 android/app/src/main/AndroidManifest.xml
    cp android/app/src/main/AndroidManifest_$1 android/app/src/debug/AndroidManifest.xml
    cp android/app/build_$1 android/app/build.gradle
    cp lib/helpers/env_config_$1.template lib/helpers/env_config.dart
    cp android/app/src/main/kotlin/org/jimber/threebotlogin/MainActivity_$1 android/app/src/main/kotlin/org/jimber/threebotlogin/MainActivity.kt 

    cp android/app/src/main/res/mipmap-hdpi/ic_launcher_$1.png android/app/src/main/res/mipmap-hdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-mdpi/ic_launcher_$1.png android/app/src/main/res/mipmap-mdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xhdpi/ic_launcher_$1.png android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xxhdpi/ic_launcher_$1.png android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_$1.png android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

    cp ios/Runner/Info_$1 ios/Runner/Info.plist

    # cp android/app/google-services_$1 android/app/google-services.json
    # cp ios/Runner/GoogleService-Info_$1 ios/Runner/GoogleService-Info.plist
}

setConfigsAndBuild() {
    sed -i -e "s/githashvalue/$githash/g" lib/helpers/env_config.dart
    sed -i -e "s/timevalue/$logcurrent_time/g" lib/helpers/env_config.dart

    if [[ "$1" == "--debug" ]]; then
        echo "Running local debug build..."
        flutter build apk -t lib/main.dart --target-platform android-arm,android-arm64 --debug
    else
        echo "Running release build..."
        flutter build apk -t lib/main.dart --target-platform android-arm,android-arm64 --release
    fi
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
    echo "Usage: ./build.sh --[run|build|switch] --[local|testing|staging|production]"
    echo "Usage: ./build.sh --init"
    exit 1
fi

if [[ $1 == "--init" ]]
then
    AndroidManifestMainPath=android/app/src/main/AndroidManifest.xml
    AndroidManifestDebugPath=android/app/src/debug/AndroidManifest.xml


    env_configFilePath=lib/helpers/env_config.dart
    AppConfigLocalFilePath=lib/app_config_local.dart
    ReflectablePath=lib/main.reflectable.dart

    BuildGradlePath=android/app/build.gradle

    LauncherImgPath1=android/app/src/main/res/mipmap-hdpi/ic_launcher.png
    LauncherImgPath2=android/app/src/main/res/mipmap-mdpi/ic_launcher.png
    LauncherImgPath3=android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
    LauncherImgPath4=android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
    LauncherImgPath5=android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

    generateFile $env_configFilePath lib/helpers/env_config_local.template
    generateFile $AppConfigLocalFilePath lib/app_config_local.template

    generateFile $BuildGradlePath android/app/build_local
    
    generateFile $LauncherImgPath1 android/app/src/main/res/mipmap-hdpi/ic_launcher_local.png
    generateFile $LauncherImgPath2 android/app/src/main/res/mipmap-mdpi/ic_launcher_local.png
    generateFile $LauncherImgPath3 android/app/src/main/res/mipmap-xhdpi/ic_launcher_local.png
    generateFile $LauncherImgPath4 android/app/src/main/res/mipmap-xxhdpi/ic_launcher_local.png
    generateFile $LauncherImgPath5 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_local.png

    mkdir android/app/src/debug
    generateFile $AndroidManifestMainPath android/app/src/main/AndroidManifest_local
    generateFile $AndroidManifestDebugPath android/app/src/main/AndroidManifest_local

    if ! test -f $ReflectablePath; then
        echo "$ReflectablePath doesn't exist, generating ..."
        dart run build_runner build
     else
        echo "$1 already exists."
    fi

    exit 0
fi

compileAndUpload "$1" "$2" "$3" "local"
compileAndUpload "$1" "$2" "$3" "testing"
compileAndUpload "$1" "$2" "$3" "staging"
compileAndUpload "$1" "$2" "$3" "production"

echo "Syntax error."
echo "Usage: ./build.sh --[[run|build|switch]] --[[local|testing|staging|production]]"
echo "Usage: ./build.sh --init"
exit 1
