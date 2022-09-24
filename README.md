This package is published mainly to pick images from instagram gallery. Once you select the images, the package will
return list of media URLs

## Installation
Add the latest version of null_safe_instagram_image_picker to pubspec.yaml (run `flutter pub get`)

```yaml
dependencies:
  null_safe_instagram_image_picker:
```

## Getting started

Import the package in your app

```dart
import 'package:null_safe_instagram_image_picker/null_safe_instagram_image_picker.dart';
```

## Usage

There are several parameters you can modify:
-backgroundColor
-appbarColor
-appbarText
-textColor

```dart

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  pickImages(BuildContext context) async {
    List mediaUrls = await InstagramImagePicker(
      appId: "---your-app-id---",
      appSecret: "---your-app-secret---",
      appbarColor: Colors.brown.withOpacity(.7),
      appbarText: "Image Picker",
      backgroundColor: Colors.grey.shade300,
      textColor: Colors.black.withOpacity(.8),
    ).pickImages(context: context);
    print(mediaUrls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
        onPressed: () async {
          await pickImages(context);
        },
        child: const Center(
          child: Text(
            "Pick Images",
          ),
        ),
      )),
    );
  }
}

```
