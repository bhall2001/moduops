# moduops

Software for Model Railroad Operations

ModuOps is a software project for Free-mo AND home layouts looking for software to assist in operation. ModuOps will generate trainlists (also known as switchlists) used during operating sessions. The software is FREE to download and includes a fully functional system with basic features. A yearly nominal subscription unlocks additional features and advanced scheduling engines.

ModuOps is designed with the nuances of operating a Free-mo modular setup as it's primary criteria. Operations in this environment are quite different than operating a static layout. As an example, in a Free-mo setup, the "layout" is different every time it is put together.

Rollingstock is not known until individuals place on the layout the items they've brought to the setup. Keeping track of individual car details adds a layer of administration that is time consuming and impractical for a setup that may only last for a single day.

Does this mean the software can not be used on your home layout? Well, no it doesn't. ModuOps is used to operate home layouts bringing a level of realism to your operating sessions without adding unnecessary complexity setting up the session. What you will see is your layout comes alive and Operators having fun while running the layout.

ModuOps is in the development phase at this point. Available here for download is the FREE version of the software containing the most basic scheduling engine and features to get you going.

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
