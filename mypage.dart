import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pie_chart/pie_chart.dart';

import 'rootfile.dart';

final Map<String, double> sampleData = new Map();

//Future<List<Nation>> fetchNations() async{
Future<List<Nation>> fetchNations() async{
  final response = await http.get(Uri.parse('https://datausa.io/api/data?drilldowns=Nation&measures=Population'));

  var respdata = json.decode(response.body);
  //print("response.body =>" + response.body);

  var respdatalist;

  try{
    respdatalist = json.decode(response.body);
    // print(respdatalist);//jobj
  }catch(e){
    print(e.toString());
  }//jobj

  /*List responseDataList = respdatalist['data'];
  print(respdatalist['data']);
  print(respdatalist['data'][0]['Nation']);
  print(respdatalist['source']);
  print(respdatalist['source'][0]['measures'][0]);
  print(respdatalist['source'][0]['annotations']['topic']);*/

  //return getParsedData(respdatalist);
  print(parseData(respdatalist));
  return parseData(respdatalist);
}

parseData(respdatalist){

  List responseDataList = respdatalist['data'];
  /* print(respdatalist['data']);
  print(respdatalist['data'][0]['Nation']);
  print(respdatalist['source']);
  print(respdatalist['source'][0]['measures'][0]);
  print(respdatalist['source'][0]['annotations']['topic']);*/

  List<Nation> nations = new List<Nation>();

  //add data list to data
  List<Data> datalist = new List<Data>();
  List<Source> sourcelist = new List<Source>();

  for (int i=0; i<responseDataList.length;i++) {
    Data data = Data(respdatalist['data'][i]["Nation"].toString(),
        respdatalist['data'][i]["ID Nation"].toString(),
        respdatalist['data'][i]["ID Year"].toString(),
        respdatalist['data'][i]["Year"].toString(),
        respdatalist['data'][i]["Population"].toString(),
        respdatalist['data'][i]["SlugNation"].toString());

    var dt = respdatalist['data'][i]["Nation"].toString()+" = "+respdatalist['data'][i]["Population"].toString();
    //print(dt);

    datalist.add(data);
  }

  for(int j =0; j<datalist.length;j++){
    sampleData.putIfAbsent(datalist[j].Year, () => double.parse(datalist[j].Population));
  }

  //print(datalist);

  Annotations ann;
  try{
    ann = new Annotations(respdatalist['source'][0]['annotations']['source_name'],
        respdatalist['source'][0]['annotations']['source_description'],
        respdatalist['source'][0]['annotations']['dataset_name'],
        respdatalist['source'][0]['annotations']['dataset_link'],
        respdatalist['source'][0]['annotations']['topic'],
        respdatalist['source'][0]['annotations']['subtopic']);
    //print(ann.toString());
  }catch(e){
    print(e.toString());
  }

  //print(respdatalist['source'][0]['measures'][0].toString());

  int len = respdatalist['source'].length;    //get length of array
  //print(len);

  List<String> strMsr = new List<String>();
  strMsr.add(respdatalist['source'][0]['measures'][0].toString());
  //print(strMsr);

  try{
    for (int i=0; i<len;i++) {
      Source source = Source(strMsr, ann,
          respdatalist['source'][i]["name"].toString(),
          respdatalist['source'][i]["substitutions"].toString());

      sourcelist.add(source);
    }
  }catch(e){
    print(e.toString());
  }

  //print(sourcelist);
  //print(sourcelist[0].name);
  //print(sourcelist[0].annotations);

  Nation nation_ = new Nation(datalist, sourcelist);
  nations.add(nation_);

  //print(nations);
  //print(nations[0].data[0].Nation_);
  //print(nations[0].source[0].name);

  return nations;

}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MyPage createState() => MyPage();
}

class MyPage extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("REST API Demo"),
        backgroundColor: Colors.black54,
        leading: Icon(Icons.home, color: Colors.white,),
      ),
      body: Container(
        child: FutureBuilder<List<Nation>>(
            future: fetchNations(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.data == null){
                return Center(child:CircularProgressIndicator());
              }else if(snapshot.hasError){
                return Text("${snapshot.error}");
              }else{

                return Container(
                    child:SingleChildScrollView(
                        physics: ScrollPhysics(),
                        child:Column(
                          children: [

                            SizedBox(height: 10,),

                            Text("United States",style:
                            TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: Colors.black),),

                            SizedBox(height: 10,),

                            Container(
                                height: 190,
                                margin: EdgeInsets.only(left:20,top:10,right:0,bottom:10),
                                alignment: Alignment.topCenter,
                                child: Expanded(
                                  child: PieChart(
                                    dataMap: sampleData,
                                    animationDuration: Duration(milliseconds: 1000),
                                    chartLegendSpacing: 25,
                                    chartType: ChartType.ring,
                                    ringStrokeWidth: 30,
                                    centerText: "Population in United States",
                                    legendOptions: LegendOptions(
                                      showLegendsInRow: false,
                                      legendPosition: LegendPosition.right,
                                      showLegends: true,
                                      legendShape: BoxShape.circle,
                                      legendTextStyle: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),
                                    ),
                                    chartValuesOptions: ChartValuesOptions(
                                      showChartValueBackground: true,
                                      showChartValues: true,
                                      showChartValuesInPercentage: false,
                                      showChartValuesOutside: false,
                                      decimalPlaces: 1,
                                    ),),
                                )
                            ),

                            SourceList(source: snapshot.data[0].source),

                            NationsList(data:snapshot.data[0].data),
                          ],
                        )
                    )

                );
              }
            }
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SourceList extends StatelessWidget{
  List<Source> source;

  SourceList({Key key,this.source}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
          color: Colors.black12,
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.all(5),
            child:Column(
              children: [
                Text(source[0].annotations.source_name,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13,color: Colors.white,),),
                Text(source[0].annotations.source_description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13,color: Colors.white),),
              ],
            ),
          )
      ),
    );
  }


}

class Nation{

  List<Data> data;
  List<Source> source;

  Nation(this.data, this.source);
}

class Data {
  String Nation_;
  String IDNation;
  String IDYear;
  String Year;
  String Population;
  String SlugNation;

  Data(this.Nation_, this.IDNation, this.IDYear, this.Year, this.Population,
      this.SlugNation);
}

class Source{
  List<String> measures;
  Annotations annotations;
  String name;
  String substitutions;

  Source(this.measures, this.annotations, this.name, this.substitutions);

}

class Annotations{
  String source_name;
  String source_description;
  String dataset_name;
  String dataset_link;
  String topic;
  String subtopic;

  Annotations(this.source_name, this.source_description, this.dataset_name,
      this.dataset_link, this.topic, this.subtopic);

}

List<PieChart> pie_chart(Map<String, dynamic> apiData){
  List<PieChart> list = new List();
  for(int i=0;i<apiData.length;i++){
    list.add(new PieChart(dataMap:apiData['data'][i]["Population"]));
  }

  return list;

}

class NationsList extends StatelessWidget {
  final List<Data> data;

  const NationsList({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        //print(snapshot.data[index].data[0].Nation_.toString());
        return Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          height: 40,
          child: InkWell(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10,),
                  Flexible(
                    fit: FlexFit.tight,
                    child: Text(data[index].Nation_.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14,fontWeight: FontWeight.normal),),),

                  Flexible(
                      fit: FlexFit.tight,
                      child:  Text(data[index].Year.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900),)),
                  Flexible(
                      fit: FlexFit.tight,
                      child:  Text(data[index].Population.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900),)),

                ],
              ),
            ),
          ),
        );

      },
    );
  }
}