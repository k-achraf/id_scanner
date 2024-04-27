import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:m7_livelyness_detection/m7_livelyness_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner/selfie_view.dart';

import 'components/enums/camera_description.dart';
import 'components/enums/id_card_face.dart';
import 'components/enums/inside_line_direction.dart';
import 'components/enums/inside_line_position.dart';
import 'components/enums/result.dart';
import 'components/inside_line.dart';
import 'components/main_crop.dart';

class BackFaceView extends StatefulWidget {
  final String idType;
  final Uint8List frontFaceImage;
  const BackFaceView({required this.idType, required this.frontFaceImage, super.key});

  @override
  State<BackFaceView> createState() => _BackFaceViewState();
}

class _BackFaceViewState extends State<BackFaceView> {

  void startLiveliness() async{

    final List<M7LivelynessStepItem> verificationSteps = [
      M7LivelynessStepItem(
        step: M7LivelynessStep.smile,
        title: "ابتسم",
        isCompleted: false,
      ),
      M7LivelynessStepItem(
        step: M7LivelynessStep.blink,
        title: "قم بالرمش",
        isCompleted: false,
      ),
    ];

    M7LivelynessDetection.instance.configure(
      thresholds: [
        M7SmileDetectionThreshold(
          probability: 0.8,
        ),
        M7BlinkDetectionThreshold(
          leftEyeProbability: 0.25,
          rightEyeProbability: 0.25,
        ),
      ],
    );

    final response = await M7LivelynessDetection.instance.detectLivelyness(
      context,
      config: M7DetectionConfig(
        steps: verificationSteps,
        startWithInfoScreen: false,
        captureButtonColor: Colors.red,
        maxSecToDetect: 15,
      ),
    );

    if (response != null){

      final File selfie = File(response);

      uploadSelfie(selfie);

    }
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> uploadSelfie(File image) async{



  }

  Future<void> uploadIdCardImages(Uint8List front, Uint8List back) async{


    final tempDir = await getTemporaryDirectory();

    File frontFace = await File('${tempDir.path}/front_face.png').create();
    frontFace.writeAsBytesSync(front);

    File backFace = await File('${tempDir.path}/back_face.png').create();
    backFace.writeAsBytesSync(back);

  }

  @override
  Widget build(BuildContext context) {
    return MaskForCameraView(
      face: IdCardFace.back,
      ocrType: widget.idType,
      boxHeight: widget.idType == "whiteIdCard" ? 178.0 : 210.0,
      boxWidth: 300.0,
      onTake: (MaskForCameraViewResult res){

        uploadIdCardImages(widget.frontFaceImage, res.croppedImage!)
            .then((value) => startLiveliness());

      },
      visiblePopButton: false,
      insideLine: MaskForCameraViewInsideLine(
        position: MaskForCameraViewInsideLinePosition.endPartThree,
        direction: MaskForCameraViewInsideLineDirection.horizontal,
      ),
      boxBorderWidth: 2.6,
      cameraDescription: MaskForCameraViewCameraDescription.rear,
    );
  }
}
