import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';


class WeatherScreen extends StatefulWidget{
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map< String , dynamic >> weather;
 
   
  Future<Map< String , dynamic >> getCurrentWeather () async{
    try{
      
      String cityName='Mumbai';
      final result =await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName,&APPID=$openWeatherAPIKey'
      ),
    );
    final data = jsonDecode(result.body);
    if(data['cod'] != '200'){
      throw 'An unexpected error occurred';
    }
      return data;
      
     
    }catch(e){
      throw e.toString();
    }
  }
  @override
  void initState() {
    super.initState();
     weather=getCurrentWeather();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
     appBar: AppBar(
      title: const Text('Weather app',
      style:TextStyle(
        fontWeight: FontWeight.bold,
      ),
      ) ,
      centerTitle:true,
      actions:[
        IconButton(
          onPressed: (){
            setState(() {
              weather=getCurrentWeather();
            });
          },
           icon: const Icon(Icons.refresh),
        )  
      ],
     ),
     body:FutureBuilder(
      future: weather,
       builder:(context,snapshot) {
      //  print(snapshot);
        if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator.adaptive()
            );
        }
        if(snapshot.hasError){
          return Center(
            child: 
            Text
            (
              snapshot.error.toString()),
          );
        }
        final data=snapshot.data!;
        final currentWeatherData=data['list'][0];

        final currentTemperature=currentWeatherData['main']['temp']; 
        final currentSky=currentWeatherData['weather'][0]['main'];
        final currentPressure=currentWeatherData['main']['pressure'];
        final currentWindspeed=currentWeatherData['wind']['speed'];
        final currentHumidity=currentWeatherData['main']['humidity'];


         return Padding(
         padding: const EdgeInsets.all(16.0),
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            //main card
            SizedBox(
              width:double.infinity,
              child: Card(
                elevation:10,
                shape:RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
                ),
                child : ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 10,
                      sigmaY: 10),
                    child:  Padding(
                      padding:const EdgeInsets.all(16.0),
                      child: Column(
                        children:[
                          Text('$currentTemperature K',
                          style:const TextStyle(
                            fontSize:32,
                            fontWeight:FontWeight.bold,
                          ),
                          ),
                          const SizedBox(height:16),
                          Icon(
                            currentSky =='Clouds'||currentSky== 'Rain'?  Icons.cloud:Icons.sunny,
                            size:65
                          ),
                        Text(
                          currentSky,
                          style:const TextStyle(
                          fontSize: 20,
                        ))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height:20),
          const Text('Hourly forecast',
            style:TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            ),
          const SizedBox(height:8),
        SizedBox(
          height:121,
          child: ListView.builder(
            itemCount: 5,
            scrollDirection: Axis.horizontal,
            itemBuilder:(context , index){
              final hourlyForecast=data['list'][index+1];
              final hourlysky=data['list'][index+1]['weather'][0]['main'] ;
              final hourlytemp=  hourlyForecast['main']['temp'].toString();
              final time = DateTime.parse( hourlyForecast['dt_txt']);
              return HourlyForecastItem(
                icon:
                      hourlysky=='Clouds'|| 
                      hourlysky =='Rain'
                      ? Icons.cloud:Icons.sunny, 
                time: 
                      DateFormat.j().format(time),
                temperature:
                      hourlytemp,
                );
            }
            ),
        ),
          //additional information
          const SizedBox(height:20),
          const Text(
            'Additional Information',
            style:TextStyle(
              fontSize:24,
              fontWeight:FontWeight.bold
              ),
          ),
          const SizedBox(height:8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:[
              AdditionalInfoitem(
                icon:Icons.water_drop,
                label:'Humidity',
                value: currentHumidity.toString(),
              ),
              AdditionalInfoitem(
                icon:Icons.air,
                label:'Wind Speed',
                value:currentWindspeed.toString(),
              ),
              AdditionalInfoitem(
                icon:Icons.beach_access,
                label:'Pressure',
                value:currentPressure.toString(),
              ),
            ]
          )
          ]
         ),
       );
       },
     ),
    );
  }
}
