#rm -f simple-rpg.apk simple-rpg-unsigned.apk simple-rpg-unaligned.apk 
(cd godot && ~/godot/bin/godot.x11.tools.64 -export Android /home/slapin/simple-rpg/simple-rpg-unsigned.apk)
rm -f simple-rpg.apk simple-rpg-unaligned.apk simple-rpg-unsigned2.zip simple-rpg-unsigned2.apk
rm -Rf simple-rpg-unsigned
unzip -d simple-rpg-unsigned simple-rpg-unsigned.apk
cd simple-rpg-unsigned
rm -Rf META-INF
zip -r ../simple-rpg-unsigned2.zip *
cd ..
mv simple-rpg-unsigned2.zip simple-rpg-unsigned2.apk

jarsigner -verbose -digestalg SHA1 -sigalg MD5withRSA -keystore ~/android/release.keystore -signedjar simple-rpg-unaligned.apk simple-rpg-unsigned2.apk slapin
/home/slapin/android-sdk-linux/tools/zipalign -v 4 simple-rpg-unaligned.apk simple-rpg.apk
#cp /home/slapin/simple-rpg/simple-rpg-unsigned.apk simple-rpg.apk
