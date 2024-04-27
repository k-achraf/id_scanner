import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomTextField extends StatelessWidget {
  final String title;
  final String hintText;
  final IconData leftIcon;
  final String rightIconAsset;
  final Color fillColor;
  final VoidCallback onTap;

  const CustomTextField({
    Key? key,
    required this.title,
    required this.hintText,
    required this.leftIcon,
    required this.rightIconAsset,
    required this.fillColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async{

        if (await Permission.camera.request().isGranted) {
          onTap.call();
        }


      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
        child: Container(
          color:  fillColor,
          child: Row(
            children: [

               SvgPicture.asset(
                rightIconAsset,
                width: 24,
                height: 24,
              ),

              SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none ,
                    filled: true,
                    fillColor: fillColor,
                  ),
                  onTap: (){
                    onTap.call();
                  },
                ),
              ),
              SizedBox(width: 10),
              Icon(leftIcon),

            ],
          ),
        ),
      ),
    );
  }
}
