import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'crop_image.dart';
import 'enums/border_type.dart';
import 'enums/camera_description.dart';
import 'enums/id_card_face.dart';
import 'enums/result.dart';
import 'inside_line.dart';

CameraController? _cameraController;
late List<CameraDescription> _cameras;
final GlobalKey _stickyKey = GlobalKey();

double? _screenWidth;
double? _screenHeight;
double? _boxWidthForCrop;
double? _boxHeightForCrop;

FlashMode _flashMode = FlashMode.auto;

// ignore: must_be_immutable
class MaskForCameraView extends StatefulWidget {
  MaskForCameraView({
    super.key,
    required this.ocrType,
    this.title = "OCR Scan",
    // this.boxWidth = 300.0,
    // this.boxHeight = 178.0,
    required this.boxWidth,
    required this.face,
    required this.boxHeight,
    this.boxBorderWidth = 1.8,
    this.boxBorderRadius = 3.2,
    required this.onTake,
    this.cameraDescription = MaskForCameraViewCameraDescription.rear,
    this.borderType = MaskForCameraViewBorderType.dotted,
    this.insideLine,
    this.visiblePopButton = true,
    this.appBarColor = Colors.black,
    this.titleStyle = const TextStyle(
      color: Colors.white,
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
    ),
    this.boxBorderColor = Colors.white,
    this.bottomBarColor = Colors.black,
    this.takeButtonColor = Colors.white,
    this.takeButtonActionColor = Colors.black,
    this.iconsColor = Colors.white,
  });

  IdCardFace face;
  String ocrType;
  String title;
  double boxWidth;
  double boxHeight;
  double boxBorderWidth;
  double boxBorderRadius;
  bool visiblePopButton;
  MaskForCameraViewCameraDescription cameraDescription;
  MaskForCameraViewInsideLine? insideLine;
  Color appBarColor;
  TextStyle titleStyle;
  Color boxBorderColor;
  Color bottomBarColor;
  Color takeButtonColor;
  Color takeButtonActionColor;
  Color iconsColor;
  ValueSetter<MaskForCameraViewResult> onTake;
  MaskForCameraViewBorderType borderType;
  @override
  State<StatefulWidget> createState() => _MaskForCameraViewState();

  static Future<void> initialize() async {
    _cameras = await availableCameras();
  }
}

class _MaskForCameraViewState extends State<MaskForCameraView> {
  bool isRunning = false;

  @override
  void initState() {
    _cameraController = CameraController(
      widget.cameraDescription == MaskForCameraViewCameraDescription.rear
          ? _cameras.first
          : _cameras.last,
      ResolutionPreset.high,
      enableAudio: false,
    );


    _cameraController!.initialize().then((_) async {
      _cameraController?.setFlashMode(FlashMode.off);
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _cameraController!.dispose();
    super.dispose();
  }


  Uint8List? picture;
  bool imageVisible = false;
  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    // _screenHeight = MediaQuery.of(context).size.height;

    _boxWidthForCrop = widget.boxWidth;
    _boxHeightForCrop = widget.boxHeight;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          picture != null && imageVisible ? Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ) : Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: !_cameraController!.value.isInitialized
                ? Container()
                : Column(
              children: [
                Expanded(
                  child: Container(
                    key: _stickyKey,
                    color: widget.appBarColor,
                  ),
                ),
                CameraPreview(
                  _cameraController!,
                ),
                Expanded(
                  child: Container(
                    color: widget.bottomBarColor,
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.takeButtonColor,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor:
                            widget.takeButtonActionColor.withOpacity(0.26),
                            onTap: () async {
                              if(imageVisible){
                                _cameraController?.setFlashMode(FlashMode.off);
                                setState(() {
                                  picture = null;
                                  imageVisible = false;
                                });
                              }
                              else{
                                if (isRunning) {
                                  return;
                                }
                                setState(() {
                                  isRunning = true;
                                });
                                MaskForCameraViewResult? res = await _cropPicture(
                                    widget.ocrType, widget.insideLine);

                                setState(() {
                                  picture = res?.croppedImage;
                                  imageVisible = true;
                                });

                                if (res == null) {
                                  throw "Camera expansion is very small";
                                }

                                setState(() {
                                  isRunning = false;
                                });

                                showModalBottomSheet(
                                  context: context,
                                  builder: (context){
                                    return Container(
                                      height: MediaQuery.of(context).size.height / 3,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'هل الصورة جيدة و سهلة القراءة ؟',
                                              style: const TextStyle(
                                                color: AppColor.textHeadlineColor,
                                                fontFamily: 'Cairo',
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 20,),
                                            Text(
                                              'يرجى التأكد من أن النص واضح وأن صفحة  الصورة بأكملها مرئية',
                                              style: const TextStyle(
                                                color: AppColor.textHeadlineColor,
                                                fontFamily: 'Cairo',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 40,),
                                            ElevatedButton(
                                              onPressed: () async {
                                                widget.onTake(res);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding: const EdgeInsets.fromLTRB(115, 15, 115, 15),
                                                backgroundColor: AppColor.buttonColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(32.0),
                                                ),
                                              ),
                                              child: const Text(
                                                'نعم ,جيدة ',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Cairo',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10,),
                                            TextButton(
                                              onPressed: (){
                                                Navigator.of(context).pop();
                                                _cameraController?.setFlashMode(FlashMode.off);
                                                setState(() {
                                                  picture = null;
                                                  imageVisible = false;
                                                });
                                              },
                                              child: Text(
                                                'اعادة التقاط الصورة',
                                                style: TextStyle(
                                                  color: AppColor.buttonColor,
                                                  fontFamily: 'Cairo',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  isScrollControlled: true,
                                  elevation: 0,
                                  barrierColor: Colors.transparent,
                                  isDismissible: false,
                                  enableDrag: false,
                                );
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.all(1.8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 2.0,
                                  color: widget.takeButtonActionColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: imageVisible ? MediaQuery.of(context).size.height / 4 : 0.0,
            bottom: imageVisible ? null : 0.0,
            left: 0.0,
            right: 0.0,
            child: Center(
              child: DottedBorder(
                borderType: BorderType.RRect,
                strokeWidth:
                widget.borderType == MaskForCameraViewBorderType.dotted
                    ? widget.boxBorderWidth
                    : 0.0,
                color: widget.borderType == MaskForCameraViewBorderType.dotted
                    ? widget.boxBorderColor
                    : Colors.transparent,
                dashPattern: const [4, 3],
                radius: Radius.circular(
                  widget.boxBorderRadius,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: isRunning ? Colors.white60 : Colors.transparent,
                    borderRadius: BorderRadius.circular(widget.boxBorderRadius),
                  ),
                  child: Container(
                    width:
                    widget.borderType == MaskForCameraViewBorderType.solid
                        ? widget.boxWidth + widget.boxBorderWidth * 2
                        : widget.boxWidth,
                    height:
                    widget.borderType == MaskForCameraViewBorderType.solid
                        ? widget.boxHeight + widget.boxBorderWidth * 2
                        : widget.boxHeight,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: widget.borderType ==
                            MaskForCameraViewBorderType.solid
                            ? widget.boxBorderWidth
                            : 0.0,
                        color: widget.borderType ==
                            MaskForCameraViewBorderType.solid
                            ? widget.boxBorderColor
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(
                        widget.boxBorderRadius,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          child: imageVisible && picture != null ? Image.memory(
                            picture!,
                            width: widget.boxWidth,
                            height: widget.boxHeight,
                          ) :
                          _IsCropping(isRunning: isRunning, widget: widget),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 6,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 8),
              child: Center(
                child: Text(
                  widget.face == IdCardFace.front ? 'التقط صورة لواجهة بطاقة الهوية الخاصة بك' : 'التقط صورة لخلفية بطاقة الهوية الخاصة بك',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<MaskForCameraViewResult?> _cropPicture(
    String ocrType, MaskForCameraViewInsideLine? insideLine) async {
  XFile xFile = await _cameraController!.takePicture();
  File imageFile = File(xFile.path);

  // ignore: use_build_context_synchronously
  RenderBox box = _stickyKey.currentContext!.findRenderObject() as RenderBox;
  double size = box.size.height * 2;
  MaskForCameraViewResult? result = await cropImage(
    ocrType,
    imageFile.path,
    _boxHeightForCrop!.toInt(),
    _boxWidthForCrop!.toInt(),
    _screenHeight! - size,
    _screenWidth!,
    insideLine,
  );
  return result;
}

///
///
// IconButton

class _IconButton extends StatelessWidget {
  const _IconButton(this.icon,
      {Key? key, required this.color, required this.onTap})
      : super(key: key);
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22.0),
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          color: color,
        ),
      ),
    );
  }
}

class _IsCropping extends StatelessWidget {
  const _IsCropping({Key? key, required this.isRunning, required this.widget})
      : super(key: key);
  final bool isRunning;
  final MaskForCameraView widget;

  @override
  Widget build(BuildContext context) {
    return isRunning && widget.boxWidth >= 50.0 && widget.boxHeight >= 50.0
        ? const Center(
        child: CupertinoActivityIndicator(
        radius: 12.8,
      ),
    )
        : Container();
  }
}