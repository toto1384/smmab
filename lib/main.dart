import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:flutter/material.dart';
import 'package:smmab/database.dart';
import 'package:smmab/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget{

  
  static bool isDarkMode = false;

  static restartApp(BuildContext context) {
    final MyAppState state =
        context.findAncestorStateOfType<MyAppState>();
    state.restartApp();
  }

  @override
  MyAppState createState() {
    return MyAppState();
  }

}

class MyAppState extends State<MyApp>{

  Key key = new UniqueKey();

  void restartApp() {
    this.setState(() {
      key = new UniqueKey();
    });
  }

  SliderThemeData sliderThemeData = SliderThemeData(
                activeTrackColor: MyColors.color_primary,
                inactiveTrackColor: MyColors.color_primary.withOpacity(0.3),
                thumbColor: MyColors.color_secondary,
                trackHeight: 8,
                overlayColor: MyColors.color_secondary.withOpacity(0.3),
                valueIndicatorColor: MyColors.color_primary,
                activeTickMarkColor: Colors.transparent,
                inactiveTickMarkColor: Colors.transparent,
              );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DataHelper.getInstance(context),
      builder: (context,AsyncSnapshot<DataHelper> snapshot){

        MyApp.isDarkMode=snapshot.hasData?snapshot.data.getIsDarkMode():false;
          
          return MaterialApp(
            title: '2TWIHTT',
            theme: ThemeData(
              fontFamily: 'Montserrat',
              accentColor: MyColors.color_secondary,
              primaryColor: MyColors.color_primary,
              cursorColor: MyColors.color_primary,
              primaryColorDark: MyColors.color_primary,
              scaffoldBackgroundColor: Colors.white,
              bottomAppBarColor:Colors.white,
              sliderTheme: sliderThemeData

            ),
            darkTheme: ThemeData(
              fontFamily: 'Montserrat',
              accentColor: MyColors.color_secondary,
              cursorColor: MyColors.color_secondary,
              sliderTheme: sliderThemeData,
              primaryColor: MyColors.color_primary,
              primaryColorDark: MyColors.color_primary,
              scaffoldBackgroundColor: MyColors.color_black,
              bottomAppBarColor: MyColors.color_black_darker,
            ),
            home: HomePage(),
            debugShowCheckedModeBanner: false,
            themeMode: MyApp.isDarkMode?ThemeMode.dark:ThemeMode.light,
        );
        
      },
    );

  }

}


class HomePage extends StatefulWidget {

  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  Map<int,String> apps = Map();
  GlobalKey<ScaffoldState> globalKey = GlobalKey();

  DataHelper dataHelper ;


  
  Future<bool> init() async{
    if(dataHelper==null){
      dataHelper = await DataHelper.getInstance(context);
    }
    if(apps.length==0){
      apps = dataHelper.getGoals()??Map();
    }
    return true;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: getAppBar('Apps'),
      body: FutureBuilder(
        future: init(),
        builder: (context, snapshot) {

          if(snapshot.hasData){
            return ListView.builder(
              itemCount: apps.length,
              itemBuilder: (ctx,index){
                return GestureDetector(
                  onTap: (){openAppPopup(apps.values.toList()[index]);},
                  child: getPadding(child: getText(apps.values.toList()[index].split('.')[0].toUpperCase())),
                );
              },
            );
          }else{
            return CircularProgressIndicator();
          }

        }
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_circle),
        onPressed: (){
          openAddSitePopup();
        },
      ),
    );
  }

  void openAppPopup(String site) {

    MathProblem mathProblem = MathProblem();
    TextEditingController answerTextEditingController = TextEditingController();
    int numberOfProblemsLeft = dataHelper.getNumberOfProblems();
    int sessionsLeft = dataHelper.getSessionsLeft(decrement: true);

    if(sessionsLeft==0){
      globalKey.currentState.showSnackBar(SnackBar(content: getText('No more sessions left. See ya tomorrow'),));
      return;
    }

    showDistivityModalBottomSheet(context, (ctx,ss){
      
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          getPadding(vertical: 15,child: getText(mathProblem.add?'${mathProblem.firstNumber}+${mathProblem.lastNumber}':'${mathProblem.firstNumber}-${mathProblem.lastNumber}')),
          getTextField(
            textEditingController: answerTextEditingController,
            textInputType: TextInputType.number,
            width: 50,
            focus: true,
            onChanged: (str){
              int answer = mathProblem.add?mathProblem.firstNumber+mathProblem.lastNumber:mathProblem.firstNumber-mathProblem.lastNumber;
              if(int.parse(answerTextEditingController.text)==answer){
                ss((){
                  numberOfProblemsLeft--;
                  answerTextEditingController.text='';
                  if(numberOfProblemsLeft==0){
                    Navigator.pop(context);
                    launchPage(context, SitePage(minuteDuration: dataHelper.getMinuteSessions(),site: site,));
                  }else{
                    mathProblem = MathProblem();
                  }
                });
              }
            },
          ),
        ],
      );
    });
  }

  void openAddSitePopup() {
    showDistivityModalBottomSheet(context, (ctx,ss){
      TextEditingController urlTEC = TextEditingController();

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          getTextField(
            textEditingController: urlTEC,
            textInputType: TextInputType.url,
            width: 250,
            focus: true,
            hint: 'Website url',
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: ()async{
              await dataHelper.addGoal(site: urlTEC.text);
              setState(() {
                apps = dataHelper.getGoals();
              });
              Navigator.pop(context);
              
            },
          )
        ],
      );
    });
  }
}

class SitePage extends StatefulWidget {

  final String site;
  final int minuteDuration;

  SitePage({Key key,@required this.site,@required this.minuteDuration}) : super(key: key);

  @override
  _SitePageState createState() => _SitePageState();
}

class _SitePageState extends State<SitePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl:widget.site ,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Card(
        shape: getShape(),
        color: MyColors.color_secondary,
        child: CountdownFormatted(
          duration: Duration(minutes: widget.minuteDuration),
          builder: (ctx,str){
            return getText(str);
          },
          onFinish: (){
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}