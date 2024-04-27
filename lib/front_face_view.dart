import 'package:flutter/material.dart';
import 'package:scanner/back_face_view.dart';
import 'package:scanner/components/enums/id_card_face.dart';

import 'components/app_colors.dart';
import 'components/enums/camera_description.dart';
import 'components/enums/inside_line_direction.dart';
import 'components/enums/inside_line_position.dart';
import 'components/enums/result.dart';
import 'components/inside_line.dart';
import 'components/main_crop.dart';

class FrontFaceView extends StatefulWidget {
  final String idType;
  const FrontFaceView({required this.idType, super.key});

  @override
  State<FrontFaceView> createState() => _FrontFaceViewState();
}

class _FrontFaceViewState extends State<FrontFaceView> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MaskForCameraView(
      face: IdCardFace.front,
      ocrType: widget.idType,
      boxHeight: widget.idType == "whiteIdCard" ? 178.0 : 210.0,
      boxWidth: 300.0,
      onTake: (MaskForCameraViewResult res){
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => BackFaceView(idType: widget.idType, frontFaceImage: res.croppedImage!,)));
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
