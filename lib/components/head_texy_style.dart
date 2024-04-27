import 'package:flutter/material.dart';

import 'app_colors.dart';

class Head extends StatefulWidget {






  final String title;

  


  const Head({
    super.key,
    required this.title,
    });


  @override
  State<Head> createState() => _HeadState();
}

class _HeadState extends State<Head> {
  @override
  Widget build(BuildContext context) {
    return      Directionality(
      textDirection: TextDirection.rtl,
      child: Row(children: [
                
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: const  Icon(
                      Icons.arrow_back,
                       color: AppColor.textHeadlineColor,
                       size: 25,
                      ),
                  ),
      
                const    SizedBox(width: 13,),
                
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: AppColor.textHeadlineColor,
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      ),
                    ),
                
                ],),
    );
  }
}