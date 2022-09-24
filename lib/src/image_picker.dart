import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class ImagesPicker extends StatefulWidget {
  const ImagesPicker({
    required this.appId,
    required this.appSecret,
    this.redirectUri = 'https://www.google.com/',
    required this.backgroundColor,
    required this.appbarColor,
    required this.appbarText,
    required this.textColor,
    Key? key,
  }) : super(key: key);

  final String appId;
  final String appSecret;
  final String redirectUri;
  final Color backgroundColor;
  final Color appbarColor;
  final String appbarText;
  final Color textColor;

  @override
  State<ImagesPicker> createState() => _ImagesPickerState();
}

class _ImagesPickerState extends State<ImagesPicker> {
  bool webViewDone = false;
  bool isLoading = true;
  List? data;

  late String appId;
  late String appSecret;
  late String redirectUri;
  late String initialUrl;

  @override
  void initState() {
    appId = widget.appId;
    appSecret = widget.appSecret;
    redirectUri = widget.redirectUri;
    initialUrl =
        'https://api.instagram.com/oauth/authorize?client_id=$appId&redirect_uri=$redirectUri&scope=user_profile,user_media&response_type=code';
    super.initState();
  }

  login(String code) async {
    final http.Response response = await http
        .post(Uri.parse('https://api.instagram.com/oauth/access_token'), body: {
      "client_id": appId,
      "redirect_uri": redirectUri,
      "client_secret": appSecret,
      "code": code,
      "grant_type": "authorization_code"
    });

    int userId = jsonDecode(response.body)["user_id"];
    String accessToken = jsonDecode(response.body)["access_token"];
    setState(() {
      webViewDone = true;
      isLoading = true;
    });
    getMedia(userId: userId, accessToken: accessToken);
  }

  getMedia({required int userId, required String accessToken}) async {
    String mediaUrl =
        'https://graph.instagram.com/me/media?fields=id,media_url&access_token=$accessToken';
    final http.Response response = await http.get(Uri.parse(mediaUrl));
    data = jsonDecode(response.body)["data"];
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: webViewDone
          ? isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: widget.appbarColor,
                  ),
                )
              : PickerScreen(
                  data: data!,
                  appbarColor: widget.appbarColor,
                  appbarText: widget.appbarText,
                  textColor: widget.textColor,
                )
          : WebView(
              initialUrl: initialUrl,
              navigationDelegate: (NavigationRequest request) {
                if (request.url.startsWith(redirectUri)) {
                  if (request.url.contains('error')) {
                    log('the url error');
                  }
                  var startIndex = request.url.indexOf('code=');
                  var endIndex = request.url.lastIndexOf('#');
                  var code = request.url.substring(startIndex + 5, endIndex);
                  log(code);
                  login(code);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
              onPageStarted: (url) => log("Page started $url"),
              javascriptMode: JavascriptMode.unrestricted,
              gestureNavigationEnabled: true,
              initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
            ),
    );
  }
}

class PickerScreen extends StatefulWidget {
  const PickerScreen({
    required this.data,
    required this.appbarColor,
    required this.appbarText,
    required this.textColor,
    Key? key,
  }) : super(key: key);

  final List data;
  final Color appbarColor;
  final String appbarText;
  final Color textColor;

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  List selectedImages = [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: Column(
          children: [
            Container(
              height: size.height * 0.07,
              width: size.width,
              color: widget.appbarColor,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context, []),
                      child: Icon(
                        Icons.close,
                        color: widget.textColor,
                      ),
                    ),
                    Text(
                      widget.appbarText,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: widget.textColor,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context, selectedImages);
                      },
                      child: Icon(
                        Icons.check,
                        color: widget.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            SizedBox(
              height: size.height * 0.8,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  children: widget.data
                      .map((e) => photoTile(size, e["media_url"]))
                      .toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget photoTile(Size size, imageUrl) {
    return InkWell(
      onTap: () {
        if (selectedImages.contains(imageUrl)) {
          selectedImages.remove(imageUrl);
        } else {
          selectedImages.add(imageUrl);
        }
        setState(() {});
      },
      child: Stack(
        children: [
          SizedBox(
            height: size.width * 0.27,
            width: size.width * 0.27,
            child: Image.network(imageUrl),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: selectedImages.contains(imageUrl)
                  ? Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            spreadRadius: 1.0,
                            blurRadius: 2.0,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.check),
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
