



import 'dart:math';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

import 'database.dart';
import 'main.dart';

getText(String text, { TextType textType, Color color,int maxLines,bool crossed,bool isCentered}){

  if(textType==null){
    textType=TextType.textTypeNormal;
  }

  if(color==null){
    color= MyApp.isDarkMode?Colors.white:MyColors.color_black;
  }

  if(crossed==null){
    crossed=false;
  }

  if(isCentered==null){
    isCentered=false;
  }

  return Text(text,maxLines: maxLines??1,style: TextStyle(fontSize: textType.size,
    color: color,
    fontWeight: textType.fontWeight,
    decoration: crossed?TextDecoration.lineThrough:TextDecoration.none
  ),textAlign: isCentered?TextAlign.center:null,);

}


getPadding({@required Widget child,double horizontal,double vertical}){
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontal??8,vertical: vertical??8),
    child: child,
  );
}


showDistivityDatePicker(BuildContext context,{@required Function(DateTime) onDateSelected}){

  Future<DateTime> dateTime =showDatePicker(
    context: context,
    firstDate: DateTime.now(),
    lastDate: DateTime(2050),
    initialDate: DateTime.now(),
  );

  dateTime.then((onValue){
    onDateSelected(onValue);
  });

}


showFeedbackBottomSheet(BuildContext context){

  TextEditingController feedBackTEC = TextEditingController();
  FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;


  showDistivityModalBottomSheet(context, (ctx,ss){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: <Widget>[

        getTextField(
          textEditingController: feedBackTEC,
          textInputType: TextInputType.text,
          width: 300,
          focus: true,
          hint: 'Your feedback goes here',
          variant: 1,
        ),

        IconButton(
          icon: Icon(Icons.send,color: getIconColor(),),
          onPressed: (){
            firebaseDatabase.reference().push().set(feedBackTEC.text);
            Navigator.pop(context);
          },
        ),
      ],



    );
  });


}


getPopupMenuItem({@required int value,@required String name, @required IconData iconData,String description}){

  return PopupMenuItem(
    value: value,
    child: ListTile(
      trailing: Icon(iconData,color: getIconColor(),),
      title: getText(name),
      subtitle: description!=null?getText(description,textType: TextType.textTypeSubNormal):null,
    ),
  );
}

showDistivitySnackBar({@required ScaffoldState scaffoldState,@required String message}){
  scaffoldState.showSnackBar(SnackBar(
    backgroundColor: MyApp.isDarkMode?MyColors.color_black_darker:Colors.white,
    elevation: 10,
    shape: getShape(bottomSheetShape: true),
    content: getText(message),
    duration: Duration(seconds: 5),
  ));
}

getTextField({@required TextEditingController textEditingController,String hint,@required int width,
  @required TextInputType textInputType,bool focus,int variant,Function(String) onChanged}){

    if(focus==null){
      focus = false;
    }

    if(variant==null){
      variant=1;
    }

  return Container(
    width: width.toDouble(),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),color: variant==1?MyApp.isDarkMode?MyColors.color_gray_darker:MyColors.color_gray_lighter:Colors.transparent),
    child: Center(
      child: Container(
        width: (width.toDouble()-30),
        child: TextFormField(
          onChanged: (str){onChanged(str);},
          autofocus: focus,
          keyboardType: textInputType,
          controller: textEditingController,
          style: TextStyle(fontSize: TextType.textTypeNormal.size,color: MyApp.isDarkMode?Colors.white:MyColors.color_black,fontWeight: TextType.textTypeNormal.fontWeight),
          decoration: InputDecoration.collapsed(
            hintText: hint??'',
            hintStyle: TextStyle(fontSize: TextType.textTypeNormal.size,color: MyApp.isDarkMode||(!MyApp.isDarkMode&&variant==1)?MyColors.color_gray:MyColors.color_gray_lighter,fontWeight: TextType.textTypeNormal.fontWeight),
          ),
        ),
      ),
    ),
  );

}

getSkeletonView(int width,int height){
  return Container(
                        height: height.toDouble(),
                        width: width.toDouble(),
                        decoration: BoxDecoration( color: MyColors.color_gray,borderRadius: BorderRadius.circular(7)),
                      );
}



getButton({int variant,@required Function onPressed,@required String text}){
  if(variant==null||variant>2){
    variant=1;
  }

  return FlatButton(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 5,vertical: 7),
      child: getText("$text",color: variant==1?MyColors.color_black:MyApp.isDarkMode?MyColors.color_secondary:MyColors.color_primary),
    ),
    onPressed: onPressed,
    shape: getShape(),
    color: variant==1?MyColors.color_secondary:Colors.transparent,
  );
}



getCheckBox(String text,bool checked,Function(bool) onCheckedChanged ){
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Checkbox(
          onChanged: onCheckedChanged,
          value: checked,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: getText(text),
      )
    ],

  );
}


Widget getSwitch(String text,bool isChecked, Function(bool isChecked) onCheckedChangedPlusSetState,){
  return Row(
    children: <Widget>[
      Switch(
        onChanged: onCheckedChangedPlusSetState,
        value: isChecked,
      ),
      getText(text)
    ],
  );
}


RoundedRectangleBorder getShape({bool bottomSheetShape,bool smallRadius}){

  if(bottomSheetShape==null){
    bottomSheetShape=false;
  }
  if(smallRadius==null){
    smallRadius=false;
  }

  if(bottomSheetShape){
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      )
    );
  }else{
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10)
    );
  }
}

DateFormat getDateFormat({bool timeNotDate}){
  if(timeNotDate==null){
    timeNotDate=false;
  }

  return DateFormat(timeNotDate?'HH:mm':'dd-MM-yy');
}

class MathProblem{
  bool add;
  int firstNumber;
  int lastNumber;

  MathProblem(){
    Random random = Random();

    this.add = random.nextInt(1)==0?false:true;
    this.firstNumber = random.nextInt(100);
    this.lastNumber = random.nextInt(100);
  }
}

getSettingsCustomAction(BuildContext context,Function onDifficultyChanged,DataHelper dataHelper){

  int curentDifficulty = dataHelper.getDificulty();

  return IconButton(
    icon: Icon(Icons.settings),
    onPressed: (){
      showDistivityModalBottomSheet(context, (ctx,ss){
        return Column(
          mainAxisSize: MainAxisSize.min,
          children:<Widget>[getPadding(vertical: 15,child: getText('Difficulty',textType: TextType.textTypeTitle))]+List.generate(3, (index){

            String title= '';
            String desc = '';

            switch(index){
              case 0: title = 'Eazy';desc = '15 minute app sessions,20 app sessions per day,8 math problems';break;
              case 1: title = 'Medium'; desc = '8 minute app sessions,12 app sessions per day,15 math problems';break;
              case 2: title = 'Hard :)'; desc = '4 minute app sessions,7 app sessions per day,25 math problems';break;
            }

            return GestureDetector(
              child: Card(
                color: curentDifficulty==index+1?MyColors.color_primary:MyApp.isDarkMode?MyColors.color_gray_darker:MyColors.color_gray_lighter,
                elevation: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    getPadding(child: getText(title,textType: TextType.textTypeSubtitle,color:curentDifficulty==index+1?Colors.white:MyApp.isDarkMode?Colors.white:MyColors.color_black)),
                    getText(desc,color: curentDifficulty==index+1?Colors.white:MyApp.isDarkMode?Colors.white:MyColors.color_black),
                  ],
                ),
                shape: getShape(),
              ),
              onTap: (){
                ss((){
                  curentDifficulty= index+1;
                });
                dataHelper.setDificulty(index+1);
                onDifficultyChanged();
                Navigator.pop(context);
              },
            );
          }),
        );
      });
    },
  );
}

Widget getAppBar(String title,{bool backEnabled,bool centered, BuildContext context,Widget customAction}){
  if(centered==null){
    centered=false;
  }
  if(backEnabled==null){
    backEnabled=false;
  }

  bool visible = true;

  if(customAction==null){
    customAction=Center();
    visible=false;
  }

  return PreferredSize(
    preferredSize: Size.fromHeight(85),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment: centered?Alignment.bottomCenter:Alignment.bottomLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Visibility(
                  visible: backEnabled,
                  child: IconButton(icon: Icon(Icons.arrow_back_ios,color: MyApp.isDarkMode?Colors.white:MyColors.color_black,),onPressed: (){Navigator.pop(context);},),
                ),
                getText(title, textType: TextType.textTypeTitle)
              ],
            ),
            Visibility(
              visible: visible,
              child: customAction,
            )
          ],
        ),
      ),
    ),
  );
}



showDistivityDialog({@required BuildContext context,@required List<Widget> actions ,@required String title,@required StateGetter stateGetter}){

  showDialog(context: context,builder: (ctx){
    return StatefulBuilder(
      builder: (ctx,setState){
        return AlertDialog(
          backgroundColor: MyApp.isDarkMode?MyColors.color_black_darker:Colors.white,
          shape: getShape(),
          actions: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: actions
              ),
            )
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: getText(title,textType: TextType.textTypeSubtitle)
              ),
              stateGetter(context,(func){
                setState((){
                  func();
                });
              }),
            ],
          ),
        );
      },
    );
  });
}


Widget getFlareCheckbox(bool enabled,{Function(bool) onCallbackCompleted,Function onTap}){
    return Container(
      width: 30,
      height: 30,
      child: GestureDetector(
        onTap: onTap,
        child: FlareActor(AssetsPath.checkboxAnimation,
          animation: enabled?'onCheck':'onUncheck',
          callback: (name){
            if(onCallbackCompleted!=null)onCallbackCompleted(name=='onCheck');
          },
        ),
      ),
    );
  }

getIconColor(){
    return MyApp.isDarkMode?Colors.white:MyColors.color_black;
}

typedef StateGetter = Widget Function( BuildContext buildContext , Function(Function) state);


showDistivityModalBottomSheet(BuildContext context, StateGetter stateGetter,{bool hideHandler}){

  if(hideHandler==null){
    hideHandler=false;
  }


  showModalBottomSheet(
    
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30))),
    backgroundColor: MyApp.isDarkMode?MyColors.color_black_darker:Colors.white,
    isScrollControlled: true,context: context,builder: (ctx){
      return StatefulBuilder(
        builder: (ctx,setState){
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Visibility(
                    visible: !hideHandler,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15,bottom: 15),
                      child: GestureDetector(
                        onTap: (){Navigator.pop(context);},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            getSkeletonView(75, 4)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: stateGetter(context,(func){
                      setState((){
                        func();
                      });
                    }),
                  )
                ],
              ),
            ),
          );
        },
      );
  },
  );
}

shareApp(){
  Share.share('Hey. So this is helping my business a bunch, and I figured out that you should try it too : https://play.google.com/store/apps/details?id=com.distivity.mangr');
}


getTabBar({@required List<String> items,@required List<int> selected, Function(int,bool) onSelected}){
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    shrinkWrap: true,
    itemCount: items.length,
    itemBuilder: (ctx,index){
      bool isSelected = selected.contains(index);
      return getPadding(
        child: getButton(
          variant: isSelected?1:2,
          onPressed: (){
            onSelected(index,!isSelected);
          },
          text: items[index],
        ),
      );
    },
  );
}


getBasicListTile(String title,IconData icon,{Function onPressed}){
  return ListTile(
    title: getText(title),
    leading: Icon(icon,color: getIconColor(),),
    onTap: (){onPressed();},
  );
}




class MyColors{
  static const Color color_primary = Color(0xff103975);
  static const Color color_secondary = Color(0xffffe161);
  static const Color color_black = Color(0xff252525);
  static const Color color_black_darker = Color(0xff202020);
  static const Color color_gray = Color(0xff999999);
  static const Color color_gray_darker = Color(0xff393939);
  static const Color color_red = Color(0xffC14242);
  static const Color color_gray_lighter = Color(0xffd6d6d6);
    
}




class TextType{

  double size;
  FontWeight fontWeight;
  TextType(this.size,this.fontWeight);

  static final TextType textTypeTitle =TextType(34,FontWeight.w800);
  static final TextType textTypeSubtitle =TextType(26,FontWeight.w700);
  static final TextType textTypeNormal =TextType(15,FontWeight.w600);
  static final TextType textTypeSubNormal =TextType(12,FontWeight.w400);
  static final TextType textTypeGigant =TextType(52,FontWeight.w900);

}


class AssetsPath{
  static var checkboxAnimation = "assets/animations/checkbox.flr";
  static var emptyIcon = "assets/svgs/empty.svg";
}

launchPage(BuildContext context , Widget page){
  Navigator.push(context, MaterialPageRoute(
    builder: (context){
      return page;
    }
  ));
}