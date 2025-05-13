#!/bin/bash
set -e

gituser=$(git config user.name)
gitbranch=$(git rev-parse --abbrev-ref HEAD)
githash=$(git log --pretty=format:'%h' -n 1)
logcurrent_time=$(date "+%H:%M:%S %d.%m.%Y")
current_time=$(date "+%Y.%m.%d-%H.%M.%S")

compileAndUpload() {
    if [[ "$2" == "--$4" ]]; then
        echo "Processing environment: $4"
        switchConfigs "$4"

        if [[ "$1" == "--run" ]]; then
            echo "[$4]: Running."
            flutter run -t lib/main.dart
        elif [[ "$1" == "--switch" ]]; then
            echo "[$4]: Switched configs."
        elif [[ "$1" == "--build" ]]; then
            echo "[$4]: Building apk."
            setConfigsAndBuild "$3"
        else
             echo "[$4]: Unknown action '$1'. Expected --run, --build, or --switch."
             exit 1
        fi
   fi
}

switchConfigs() {
    echo "Switching configs for $1..."
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
    echo "Configs switched."
}

setConfigsAndBuild() {
    echo "Setting build configs and building..."
    sed -i -e "s/githashvalue/$githash/g" lib/helpers/env_config.dart
    sed -i -e "s/timevalue/$logcurrent_time/g" lib/helpers/env_config.dart

    local build_command=""

    if [[ "$1" == "--debug" ]]; then
        echo "Preparing debug build command..."
        build_command="flutter build apk -t lib/main.dart --target-platform android-arm,android-arm64 --debug"
    elif [[ "$1" == "--release" ]]; then
        echo "Preparing release build command..."
        build_command="flutter build apk -t lib/main.dart --target-platform android-arm,android-arm64 --release"
    else
        echo "Unknown build type '$1'. Expected --debug or --release."
        exit 1
    fi

    echo "Executing build command: $build_command"
    $build_command

    local exit_code=$?
    echo "Build command finished with exit code: $exit_code"

    if [ $exit_code -ne 0 ]; then
        echo "Flutter build command failed with exit code $exit_code."
        exit $exit_code
    fi

    echo "Flutter build command finished successfully."
}

generateFile () {
    if ! test -f "$1"; then
        echo "$1 doesn't exist, generating from $2..."
        cp "$2" "$1"
     else
        echo "$1 already exists."
    fi
}

if [[ "$1" == "--help" ]]; then
    echo "Usage: ./build.sh --[run|build|switch] --[local|testing|staging|production] [--debug|--release]"
    echo "Usage: ./build.sh --init"
    echo "Note: --debug or --release is only needed with --build"
    exit 0
fi

if [[ "$1" == "--init" ]]; then
    echo "Running init process..."
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

    generateFile "$env_configFilePath" lib/helpers/env_config_local.template
    generateFile "$AppConfigLocalFilePath" lib/app_config_local.template

    generateFile "$BuildGradlePath" android/app/build_local

    generateFile "$LauncherImgPath1" android/app/src/main/res/mipmap-hdpi/ic_launcher_local.png
    generateFile "$LauncherImgPath2" android/app/src/main/res/mipmap-mdpi/ic_launcher_local.png
    generateFile "$LauncherImgPath3" android/app/src/main/res/mipmap-xhdpi/ic_launcher_local.png
    generateFile "$LauncherImgPath4" android/app/src/main/res/mipmap-xxhdpi/ic_launcher_local.png
    generateFile "$LauncherImgPath5" android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_local.png

    if [ ! -d "android/app/src/debug" ]; then
        echo "Creating android/app/src/debug directory..."
        mkdir android/app/src/debug
    fi
    generateFile "$AndroidManifestMainPath" android/app/src/main/AndroidManifest_local
    generateFile "$AndroidManifestDebugPath" android/app/src/main/AndroidManifest_local

    if ! test -f "$ReflectablePath"; then
        echo "$ReflectablePath doesn't exist, generating with build_runner..."
        dart run build_runner build --delete-conflicting-outputs
     else
        echo "$ReflectablePath already exists."
    fi

    echo "Init process completed."
    exit 0
fi

compileAndUpload "$1" "$2" "$3" "local" && exit 0
compileAndUpload "$1" "$2" "$3" "testing" && exit 0
compileAndUpload "$1" "$2" "$3" "staging" && exit 0
compileAndUpload "$1" "$2" "$3" "production" && exit 0

echo "Syntax error: Invalid environment argument '$2'."
echo "Usage: ./build.sh --[run|build|switch] --[local|testing|staging|production] [--debug|--release]"
echo "Usage: ./build.sh --init"
exit 1
