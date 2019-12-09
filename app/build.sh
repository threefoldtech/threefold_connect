#!/bin/bash
shouldBuild=0

if [[ $1 == "--help" ]]
then
    echo "Usage: ./build.sh --[run|build|switch] --[local|staging|production]"
    exit 1
fi

if [[ $2 == "--local" ]]
then
    cp android/app/google-services-local.json android/app/google-services.json

    if grep -q "org.jimber.threebotlogin.staging" "android/app/build.gradle";
    then
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/build.gradle
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/src/debug/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/android:label="3bot_staging"/android:label="3bot"/g' android/app/src/main/AndroidManifest.xml   
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/src/profile/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' ios/Runner/Info.plist
    fi

    if ! grep -q "org.jimber.threebotlogin.local" "android/app/build.gradle";
    then
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.local/g' android/app/build.gradle
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.local/g' android/app/src/debug/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.local/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/android:label="3bot"/android:label="3bot_local"/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.local/g' android/app/src/profile/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.local/g' android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.local/g' ios/Runner/Info.plist
    fi

    if [[ $1 == "--run" ]]
    then
        echo "flutter run -t lib/main_local_alex.dart"
        flutter run -t lib/main_local_alex.dart
    elif [[ $1 == "--switch" ]]
    then
        echo "Switched configs local."
    else
        echo "flutter build apk -t lib/main_local_alex.dart"
        flutter build apk -t lib/main_local_alex.dart
    fi

    exit 0
fi

if [[ $2 == "--staging" ]]
then
    cp android/app/google-services-staging.json android/app/google-services.json

    if grep -q "org.jimber.threebotlogin.local" "android/app/build.gradle";
    then
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/build.gradle
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/src/debug/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/android:label="3bot_local"/android:label="3bot"/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/src/profile/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' ios/Runner/Info.plist
    fi

    if ! grep -q "org.jimber.threebotlogin.staging" "android/app/build.gradle";
    then
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.staging/g' android/app/build.gradle
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.staging/g' android/app/src/debug/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.staging/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/android:label="3bot"/android:label="3bot_staging"/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.staging/g' android/app/src/profile/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.staging/g' android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.staging/g' ios/Runner/Info.plist
    fi

    if [[ $1 == "--run" ]]
    then
        echo "flutter run -t lib/main_staging.dart"
        flutter run -t lib/main_staging.dart
    elif [[ $1 == "--switch" ]]
    then
        echo "Switched configs staging."
    else
        echo "flutter build apk -t lib/main_staging.dart"
        flutter build apk -t lib/main_staging.dart
        hash=$(git rev-parse --verify HEAD)
        md5sum=$(md5sum build/app/outputs/apk/release/app-release.apk)
        curl -s -X POST "https://api.telegram.org/bot868129294:AAGLGOySYvJJxvIcMHY3XHFaPEPq2MpdGys/sendDocument" -F chat_id=-1001186043363 -F document="@build/app/outputs/apk/release/app-release.apk" -F caption="Staging build: $hash; MD5: $md5sum"
        curl -s -X POST "https://api.telegram.org/bot868129294:AAGLGOySYvJJxvIcMHY3XHFaPEPq2MpdGys/sendMessage" -d chat_id=-1001186043363 -d text="MD5: $md5sum"
        paplay /usr/share/sounds/gnome/default/alerts/glass.ogg
    fi

    exit 0
fi

if [[ $2 == "--production" ]]
then
    cp android/app/google-services-prod.json android/app/google-services.json

    if grep -q "org.jimber.threebotlogin.local" "android/app/build.gradle";
    then
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/build.gradle
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/src/debug/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/android:label="3bot_local"/android:label="3bot"/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/src/profile/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' ios/Runner/Info.plist
    fi

    if grep -q "org.jimber.threebotlogin.staging" "android/app/build.gradle";
    then
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/build.gradle
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/src/debug/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/android:label="3bot_staging"/android:label="3bot"/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/src/profile/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' ios/Runner/Info.plist
    fi

    if [[ $1 == "--run" ]]
    then
        echo "flutter run -t lib/main_prod.dart"
        flutter run -t lib/main_prod.dart
    elif [[ $1 == "--switch" ]]
    then
        echo "Switched configs to production."
    else
        echo 'oooo'
        echo "flutter build apk -t lib/main_prod.dart"
        flutter build appbundle -t lib/main_prod.dart  
        # hash=$(git rev-parse --verify HEAD)
        # md5sum=$(md5sum build/app/outputs/apk/release/app-release.apk)
        # curl -s -X POST "https://api.telegram.org/bot868129294:AAEAKE_v8ctmh472stPHtK8ZnP__pNu4448/sendDocument" -F chat_id=-1001186043363 -F document="@build/app/outputs/apk/release/app-release.apk" -F caption="Production build: $hash; MD5: $md5sum"
        # curl -s -X POST "https://api.telegram.org/bot868129294:AAEAKE_v8ctmh472stPHtK8ZnP__pNu4448/sendMessage" -d chat_id=-1001186043363 -d text="MD5: $md5sum"
        # paplay /usr/share/sounds/gnome/default/alerts/glass.ogg
    fi

    exit 0
fi

echo "Syntax error."
echo "Usage: ./build.sh --[[run|build|switch]] --[[local|staging|production]]"
exit 1