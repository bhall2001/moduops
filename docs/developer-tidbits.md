## Build binaries

- Open stack "LevureStandalone"
- enter `levurePackageApplication "release"` in message box

a notice may come up that a stack is already in use. Not sure what that is. Just click "Purge"

## Build macOS application

The built binaries are located in the project folder in the `builds/release` directory. Each version will have directory with the app version number of build number. Open the dir for the version being released. Confirm there is a single file named ModuOps in the macos directory.

## Sign the Application

The steps to signing below are based on the article below...
https://lessons.livecode.com/m/4071/l/1122100-codesigning-and-notarizing-your-lc-standalone-for-distribution-outside-the-mac-appstore

Steps at a high level...

### Code sign and notarize app

```
sudo xattr -cr <path_to_app_bundle>
```

```
sudo chmod -R u+rw <path_to_app_bundle>
```

```
codesign --deep --force --verify --verbose --sign "Developer ID Application: <certificate name>" --options runtime <path_to_app_bundle>
```

- get the app notorized

```
xcrun altool -type osx --notarize-app --primary-bundle-id "<bundle_identifier>" --username "<apple_user_name>" --password "<app_specific_password>" --file <path_to_ZIPPED_app>
```

- wait for an email that the app has been notarised. Now staple this to the app...

```
xcrun altool -type osx --notarize-app --primary-bundle-id "<bundle_identifier>" --username "<apple_user_name>" --password "<app_specific_password>" --file <path_to_ZIPPED_app>
```

### Create the .dmg file in DropDMG

- launch `DropDMG`
- in the window that opens there is a pop up. select `moduops`
- drag/drop SIGNED application onto the DropDMG window
- after DMG is created rename it as follows: `ModuOps-x_y_z-Mac.dmg` where x,y,z are the version number being released
- code sign the package with the developer id

### Code sign and notarize .dmg file

Now that the dmg file is created, we need to sign it.

1. Sign the DMG

```
codesign --deep --force --verify --verbose --sign "<your_developer_id_application>" --options runtime "<path_to_dmg>"
```
