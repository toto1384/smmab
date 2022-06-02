

import 'package:smmab/utils.dart';

class DateValueObject{
  int value;
  DateTime dateTime;

  DateValueObject(this.dateTime,this.value);


  Map<String,dynamic> toMap(){
    return {
      'value':value,
      'date':getDateFormat().format(dateTime),
    };
  }

  static DateValueObject fromMap(Map map){
    return DateValueObject(
      getDateFormat().parse(map['date']),map['value']
    );
  }
}