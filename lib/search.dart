import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cheezam/resultpage.dart';
import 'package:cheezam/theme.dart';
import 'package:cheezamapi/cheezamapi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  State createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  var loading = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    //todo see to find a way to make it rotable
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  void initAds() {
    InterstitialAd.load(
        adUnitId: "ca-app-pub-3940256099942544/8691691433", //debug
        request: const AdRequest(
            keywords: ["cheese","wine", "delicatessen" ,"sausage"]
        ),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  @override
  dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initAds();
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '🧀 Tap to find cheese',
                    style: TextStyle(
                        color: AppTheme.lightColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                  AvatarGlow(
                    glowColor: AppTheme.mainColor,
                    endRadius: 200.0,
                    // animate: vm.isRecognizing,
                    child: GestureDetector(
                      onTap: () async => searchCamera(),
                      child: Material(
                        shape: const CircleBorder(),
                        elevation: 8,
                        child: Container(
                          padding: const EdgeInsets.only(
                              right: 30, left: 30, top: 25, bottom: 35),
                          height: 200,
                          width: 200,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.mainColor),
                          child: Container(
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/images/cheese.png',
                              color: AppTheme.lightColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async => searchGallery(),
                    child: Material(
                      shape: const CircleBorder(),
                      elevation: 8,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: AppTheme.mainColor),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.file_copy,
                            color: AppTheme.lightColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (loading)
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  color: AppTheme.mainColor,
                  child: Center(
                    child: Container(
                        padding: const EdgeInsets.only(right: 70, bottom: 100),
                        child: Lottie.asset(
                          'assets/lottie/cheese.json',
                          controller: _controller,
                          onLoaded: (composition) {
                            _controller
                              ..resync(this)
                              ..duration = const Duration(milliseconds: 700)
                              ..repeat();
                          },
                        )),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  final ImagePicker _picker = ImagePicker();

  searchCamera() async {
    if (!loading) {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      search(photo);
    }
  }

  searchGallery() async {
    if (!loading) {
      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
      search(photo);
    }
  }

  search(XFile? file) async {
    if (file != null) {
      setState(() {
        loading = true;
      });
      var compressedFile = await compressXFile(file);
      if (compressedFile != null) {
        Response response = await CheezamApi.cheeze(compressedFile);
        Navigator.push(context,
                MaterialPageRoute(builder: (context) => ResultPage(response, compressedFile, _interstitialAd)))
            .then((value) => setState(() => loading = false));
      }
    } else {
      setState(() => loading = false);
    }
  }

  Future<File?> compressXFile(XFile file) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath =
        tempDir.path + "/" + DateTime.now().millisecondsSinceEpoch.toString() + file.name;
    var result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      tempPath,
      quality: 70, //Compress gradually
    );
    return result;
  }
}
