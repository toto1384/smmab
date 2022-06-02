import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smmab/date_value_object.dart';

class DataHelper {


  Map<String,dynamic> data;
  Directory localDirectory;
  int timesOpened;




  DataHelper();

  static DataHelper _dataHelper;

  static Future<DataHelper> getInstance(BuildContext context,{Function onDataUpdated})async{

    if(_dataHelper==null){
      _dataHelper=DataHelper();
    }

    if(_dataHelper.localDirectory==null){
      _dataHelper.localDirectory =await getApplicationDocumentsDirectory();
    }

    File file = File(join(_dataHelper.localDirectory.path,"data.json"));

    if(!await file.exists()){
      await file.create();
      file.writeAsString(jsonEncode({}));
      _dataHelper.data = jsonDecode(await file.readAsString());
    }else{
      _dataHelper.data = jsonDecode((await file.readAsString())??'  ');
    }

    return _dataHelper;
  }

  
  


  /////////goals
 Future addGoal({@required String site,int id}) async {

    if(id ==null){
      id=await getIdCount();
    }

    Map<int,String> apps = data[DBConstants.apps]??Map();

    apps[id]=site;
    

    data[DBConstants.apps]=apps;
    await saveJson();
  }

  Map<int,String> getGoals(){

    Map<int,String> apps = data[DBConstants.apps]??Map();

    return apps;
  }


  deleteApp(int siteId) async {

    Map<int,String> apps = data[DBConstants.apps];

    apps.remove(siteId);
    data[DBConstants.apps]=apps;
    await saveJson();

  }
////////





  getIdCount() async {
    int id= data[DBConstants.id]??-1;


    data[DBConstants.id]= id+1;
    await saveJson();


    return id;
  }

  getIsDarkMode(){
    return data[DBConstants.darkMode]??false;
  }

  setIsDarkMode()async{
    data[DBConstants.darkMode]=!data[DBConstants.darkMode];
    await saveJson();
  }

  getDificulty(){
    return data[DBConstants.dificulty]??2;
  }

  setDificulty(int dificulty)async{
    data[DBConstants.dificulty] = dificulty;
    await saveJson();
  }


  getNumberOfProblems(){
    switch(getDificulty()){
      case 1 :return 8;
      case 2: return 15;
      case 3 : return 25;
    }
  }

  getMinuteSessions(){
    switch(getDificulty()){
      case 1 :return 15;
      case 2: return 8;
      case 3 : return 4;
    }
  }

  getSessionsLeft( {@required bool decrement}){
    DateValueObject dateValueObject = DateValueObject.fromMap(data[DBConstants.sessionsLeft]);

    if(dateValueObject==null||dateValueObject.dateTime.day!=DateTime.now().day){
      int totalSessions = 0;

      switch(getDificulty()){
        case 1:totalSessions = 20;break;
        case 2:totalSessions = 12;break;
        case 3:totalSessions = 7;break;
      }


      dateValueObject = DateValueObject(DateTime.now(), totalSessions);
    }

    if(decrement){
      dateValueObject.value--;
    }

    data[DBConstants.sessionsLeft] = dateValueObject.toMap();
    saveJson();
    return dateValueObject.value+1;
  }




  saveJson()async{
    await File(join(localDirectory.path,"data.json")).writeAsString(jsonEncode(data));
  }

}

class DBConstants{

  static const String apps = 'Apps';
  static const String id = 'id';
  static const String darkMode = 'darkMode';
  static const String dificulty = 'diff';
  static const String sessionsLeft = 'ssl';


}