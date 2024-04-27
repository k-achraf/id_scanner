import 'package:flutter/material.dart';
import 'package:scanner/front_face_view.dart';

import 'components/app_colors.dart';
import 'components/custom_btn_for_take_pictures.dart';
import 'components/head_texy_style.dart';
import 'components/main_crop.dart';

class TakePersonalPicture extends StatefulWidget {
  const TakePersonalPicture({super.key});

  @override
  State<TakePersonalPicture> createState() => _TakePersonalPictureState();
}

class _TakePersonalPictureState extends State<TakePersonalPicture> {

  @override
  initState() {
    WidgetsFlutterBinding.ensureInitialized();
    initPlatform();
    super.initState();
  }

  Future<void> initPlatform() async {
    await MaskForCameraView.initialize();
  }

  //ocr type
  final List<Map<String, Object>> _rdoOcrType = [
    {'id': 'idCard', 'name': 'ID Card'},
    {'id': 'passport', 'name': 'Passport'},
  ];

  String idType = '';

  @override
  Widget build(BuildContext context) {
    return   Scaffold(


      body : SafeArea(
        top: true,
        bottom: true,
        child: Padding(

          padding: EdgeInsets.all(16),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
                children : [

                  Head(title:'حدد نوع الهوية الخاصة بك'),



                  SizedBox(height: 40,),



                  const   Text(

                    ' محتوى خاص قم بادراجه هنا محتوى خاص قم بادراجه هنا محتوى خاص قم بادراجه هنا محتوى خاص ',

                    style: TextStyle(

                      color: AppColor.secondaryTextcolor,
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      //  fontWeight: FontWeight.w600,
                    ),

                  ),

                  SizedBox(height: 50,),


                  CustomTextField(
                    title: 'جواز السفر',
                    rightIconAsset: 'assets/images/arcticons_id-wallet.svg',
                    leftIcon: Icons.arrow_right,
                    hintText:  'جواز السفر',
                    fillColor: AppColor.fillcolor,
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FrontFaceView(
                                idType: 'passport',
                              )),
                      );
                    },
                  ),

                  CustomTextField(
                    title: 'بطاقة التعريف ',
                    rightIconAsset: 'assets/images/arcticons_id-wallet.svg',
                    leftIcon: Icons.arrow_right,
                    hintText:  'بطاقة التعريف ',
                    fillColor: AppColor.fillcolor,
                    onTap: (){

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FrontFaceView(
                              idType: 'whiteIdCard',
                            )),
                      );
                    },
                  ),

                  SizedBox(height: 50,),

                  Text('من خلال تحديد نوع هويتك، فإنك توافق على أنه يمكننا جمع و استخدام وتخزين معلومات القياسات الحيوية الخاصة بك للتحقق من الهوية،  تعرف على المزيد في سياسة الخصوصية' ,
                    style: TextStyle(
                      color: AppColor.secondaryTextcolor,
                      fontFamily: 'Cairo',
                      fontSize: 14,),



                  )


















                ]),
          ),
        ),
      ),



    );
  }
}