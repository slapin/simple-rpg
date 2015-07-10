jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore ~/android/my-release-key.keystore simple-rpg.apk alias_name
mv simple-rpg.apk simple-rpg-unaligned.apk
/home/slapin/android-sdk-linux/tools/zipalign -v 4 simple-rpg-unaligned.apk simple-rpg.apk
