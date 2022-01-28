import 'dart:io';
import 'dart:typed_data';

import 'package:badges/badges.dart';
import 'package:cheezam/theme.dart';
import 'package:cheezamapi/cheezamapi.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image/image.dart' as img;
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultPage extends StatefulWidget {
  Response response = Response();
  File image;
  InterstitialAd? interstitialAd;

  ResultPage(this.response, this.image, this.interstitialAd, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ResultPage(response);
  }
}

class _ResultPage extends State<ResultPage> with TickerProviderStateMixin {
  Response response = Response();
  late final AnimationController _controller;
  var loading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  dispose() {
    super.dispose();
    _controller.dispose();
  }

  _ResultPage(this.response);

  @override
  Widget build(BuildContext context) {
    if (response == Response() ||
        response.predictions == null ||
        response.predictions!.isEmpty) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: Container(
            color: AppTheme.backgroundColor,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 14.0, right: 14.0, bottom: 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lottie/notfound.json',
                        controller: _controller,
                        onLoaded: (composition) {
                          _controller
                            ..resync(this)
                            ..duration = composition.duration
                            ..repeat();
                        },
                      ),
                      const Center(
                        child: Text(
                          "Sorry there is no cheese here",
                          style: TextStyle(color: AppTheme.lightColor, fontSize: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      widget.interstitialAd?.show();
      return SafeArea(
        child: Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 120),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _getMainChildren()),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _getCheeseNames() {
    var cheeses = <Widget>[];
    for (var prediction in response.predictions!) {
      if (prediction != null) {
        if (prediction.humanname != null) {
          cheeses.add(
            Badge(
              toAnimate: false,
              shape: BadgeShape.square,
              borderRadius: BorderRadius.circular(8),
              badgeColor: Colors.transparent,
              padding: EdgeInsets.all(4),
              badgeContent: Wrap(
                children: [
                  const Icon(
                    Icons.assignment_rounded,
                    size: 14,
                    color: AppTheme.lightColor,
                  ),
                  Text(
                    prediction.humanname!,
                    style: const TextStyle(
                      color: AppTheme.lightColor,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Wrap(
          spacing: 6.0,
          alignment: WrapAlignment.center,
          runSpacing: 2.0,
          children: cheeses),
    );
  }

  Widget _getTopWidget() {
    return Container(
      // color: AppTheme.mainColor,
      child: Column(
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                widget.image,
                height: 300,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          _getCheeseNames(),
        ],
      ),
    );
  }

  List<int> getCroppedCheeseAsBytes(double x, double y, double w, double h) {
    final image = img.decodeImage(widget.image.readAsBytesSync())!;
    int rx = (image.width * x).round();
    int ry = (image.height * y).round();
    int rw = (image.width * w).round();
    int rh = (image.height * h).round();
    return img.encodePng(img.copyCrop(image, rx, ry, rw, rh));
  }

  List<Widget> _getFoundCheese(Response response) {
    List<Widget> widgets = [];
    if (response.predictions != null) {
      response.predictions!.sort(
          (a, b) => ((b!.probability! - a!.probability!) * 10000).round());
      for (var prediction in response.predictions!) {
        widgets.add(Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Card(
            color: AppTheme.mainColor,
            elevation: 8.0,
            child: Column(
              children: [
                ListTile(
                  leading: prediction!.detection_box != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            Uint8List.fromList(
                              getCroppedCheeseAsBytes(
                                  prediction.detection_box![0],
                                  prediction.detection_box![1],
                                  prediction.detection_box![2],
                                  prediction.detection_box![3]),
                            ),
                            height: 150,
                          ),
                        )
                      : null,
                  title: prediction.humanname != null
                      ? RichText(
                          text: TextSpan(children: <TextSpan>[
                            const TextSpan(
                                text: "Name: ",
                                style: TextStyle(
                                    color: AppTheme.lightColor,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: prediction.humanname!,
                                style: const TextStyle(color: AppTheme.lightColor))
                          ]),
                        )
                      : null,
                  subtitle: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        const TextSpan(
                            text: "Probability: ",
                            style: TextStyle(
                                color: AppTheme.lightColor,
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: (prediction.probability! * 100)
                                    .round()
                                    .toString() +
                                "%",
                            style: const TextStyle(color: AppTheme.lightColor))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
      }
    }
    return widgets;
  }

  List<Widget> _getMainChildren() {
    List<Widget> widgets = [];
    widgets.add(_getTopWidget());
    widgets.add(const SizedBox(height: 40));
    widgets.add(const Text(
      "We found this: ",
      style: TextStyle(color: AppTheme.lightColor, fontSize: 20),
    ));
    widgets.add(const SizedBox(height: 20));
    widgets.addAll(_getFoundCheese(response));
    widgets.add(const SizedBox(height: 40));
    widgets.add(const Text(
      "We recommend you: ",
      style: TextStyle(color: AppTheme.lightColor, fontSize: 20),
    ));
    widgets.add(const SizedBox(height: 20));
    widgets.addAll(_getRecommendations());
    return widgets;
  }

  List<Widget> _getRecommendations() {
    List<Widget> widgets = [];
    if (response.rec != null) {
      var recommendations = uniqueReco(response.rec!);
      for (var rec in recommendations) {
        widgets.add(Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Card(
            color: AppTheme.mainColor,
            elevation: 8.0,
            child: Column(
              children: [
                ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(rec.imgurl!, height: 150),
                    ),
                    title: rec.name != null
                        ? RichText(
                            text: TextSpan(children: <TextSpan>[
                              const TextSpan(
                                  text: "Name: ",
                                  style: TextStyle(
                                      color: AppTheme.lightColor,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: rec.name!,
                                  style: const TextStyle(color: AppTheme.lightColor))
                            ]),
                          )
                        : const Text(""),
                    subtitle: rec.affiliatedURL != null
                        ? Container(
                            child: RichText(
                              text: TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => launch(rec.affiliatedURL!),
                                  children: <TextSpan>[
                                    const TextSpan(
                                        text: "Link: ",
                                        style: TextStyle(
                                            color: AppTheme.lightColor,
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text: rec.affiliatedURL!,
                                        style: const TextStyle(
                                            color: AppTheme.lightColor)),
                                  ]),
                            ),
                          )
                        : null),
              ],
            ),
          ),
        ));
      }
    }
    return widgets;
  }
}

List<Recommandation> uniqueReco(List<Recommandation?> list) {
  List<Recommandation> recoList = [];
  for (var element in list) {
    var add = true;
    for (var reco in recoList) {
      if (element!.name == reco.name) {
        add = false;
      }
    }
    if (add) {
      recoList.add(element!);
    }
  }
  return recoList;
}
