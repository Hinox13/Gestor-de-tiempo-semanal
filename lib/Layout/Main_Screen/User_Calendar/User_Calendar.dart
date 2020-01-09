import 'dart:core';
import 'package:projecte_visual/classes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projecte_visual/funcions.dart';
import 'package:table_calendar/table_calendar.dart';

class User_Calendar extends StatefulWidget {
  String idgroup, idasset, iduser;
  User_Calendar({this.idgroup, this.idasset, this.iduser});
  @override
  _User_CalendarState createState() => _User_CalendarState();
}

class _User_CalendarState extends State<User_Calendar> {
  CalendarController _calendarController;
  Map<DateTime, List> _events = {};
  List _selectedEvents;
  List<DateTime> time;
  String name;
  void initState() {
    final _selectedDay = today();
    _selectedEvents = _events[today()] ?? [];
    _calendarController = CalendarController();
    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  DateTime select;

  @override
  Widget build(BuildContext context) {
    String iduser = this.widget.iduser;

    Widget buildEventList(DateTime select, List<Event> events) {
      return ListView.builder(
        itemCount: _selectedEvents.length,
        itemBuilder: (context, index) {
          dynamic e = _selectedEvents[index];
          //document(e['userid'])
          return StreamBuilder(
            stream: Firestore.instance.collection('users').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshoti) {
            if (!snapshoti.hasData) {
              return Center(child: CircularProgressIndicator());
            }
          List<DocumentSnapshot> docos = snapshoti.data.documents; //No ha petao
          List<User> users = docaUser_list(docos);
           for (var user in users){
            if(user.id == e['userid']) name = user.name;
           }
            return Container(
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(width: 0.8),
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                title: Text('Reservation'),
                leading: Text(name),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                        'From: ${e['init'].hour}:${e['init'].minute}:${e['init'].second}'),
                    Text(
                        'To: ${e['end'].hour}:${e['init'].minute}:${e['init'].second}'),
                    SizedBox(width: 20),
                  ],
                ),
                onTap: () => print(e),
                onLongPress: () {
                  setState(() {
                    _selectedEvents.removeAt(index);
                    Firestore.instance
                        .collection('event')
                        .document(e['eventid'])
                        .delete();
                  });
                },
              ),
            );
          });
        },
      );
    }
///////////////////////////////////////////////////////////////////////////

    return Scaffold(
      appBar: AppBar(
        title: Text('Reserve Calendar'),
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('event')
            .where('userid', isEqualTo: iduser)
            .snapshots(), //Filtrem de firebase només els que tenen la id que ens interessen
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> docs = snapshot.data.documents; //No ha petao
          List<Event> events = docaEvent_list(docs);
          _events.clear();
          for (var eve in events) {
            addEvent(
                yearmonthday(eve.init),
                {
                  'userid': eve.userid,
                  'eventid': eve.eventid,
                  'init': eve.init,
                  'end': eve.end
                },
                _events);
          }

          return Column(children: <Widget>[
            TableCalendar(
              calendarController: _calendarController,
              events: _events,
              calendarStyle: CalendarStyle(
                todayColor: Colors.deepPurple,
                selectedColor: Colors.pink,
              ),
              onDaySelected: (date, events) {
                setState(() {
                  select = date;
                  _selectedEvents = events;
                }); //FIREBASE: En aquesta part es descargarn els events que te guardat el asset seleccionat. Com que tenim la variable date que ens diu el dia
                //en format DateTame només s'haurà de filtrar
              },
            ),
            const SizedBox(height: 8.0),
            Expanded(child: buildEventList(select, events)),
          ]);
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            print(iduser);
          }),
    );
  }
}
/*
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:projecte_visual/classes.dart';
import 'package:projecte_visual/funcions.dart';
import 'package:table_calendar/table_calendar.dart';

class User_Calendar1 extends StatefulWidget {
  @override
  _User_Calendar1State createState() => _User_Calendar1State();
}

class _User_Calendar1State extends State<User_Calendar1> {
  CalendarController _calendarController;
  Map<DateTime, List> _events = {};
  List _selectedEvents;

  /*addEvent(DateTime date, String name) {
    if (_events.containsKey(date)) {
      _events[date].add(name);
    } else {
      _events[date] = [name];
    }
    ID BATERIA 2XaGydRA9dYh0ePMDwoc
  }*/

  void initState() {
    final _selectedDay = today();
     _selectedEvents = _events[today()] ?? [];
    _calendarController = CalendarController();
    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime select;
List<Event> events;
    Widget buildEventList(DateTime select) {
      return ListView(
          children: _selectedEvents.asMap().entries.map((event) {
        int idx = event.key;
        return Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.8),
            borderRadius: BorderRadius.circular(12.0),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text(event.value),
            onTap: () => print(event.value),
            onLongPress: () {
              setState(() {
                /*Firestore.instance
                    .collection('event')
                    .document(event.value['eventid'])
                    .delete();*/
              });
            },
          ),
        );
      }).toList());
    }
String iduser = 'OQQkPrCOGWUau2APBMrSpDWTGTp1';
    return Scaffold(
      appBar: AppBar(
        title: Text('Reserve Calendar'),
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('event')
            .where('userid', isEqualTo: iduser)
            .snapshots(), //Filtrem de firebase només els que tenen la id que ens interessen
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<DocumentSnapshot> docs = snapshot.data.documents; //No ha petao
          events = docaEvent_list(docs);
          _events.clear();
          for (int i = 0; i < events.length; i++){
            addEvent1(events[i].init, events[i].userid, _events);
          }
          
          return Column(children: <Widget>[
            TableCalendar(
              calendarController: _calendarController,
              events: _events,
              calendarStyle: CalendarStyle(
                todayColor: Colors.deepPurple,
                selectedColor: Colors.pink,
              ),
              onDaySelected: (date, events) {
                select = date;
                print(events);
                setState(() {
                  _selectedEvents = events;
                }); //FIREBASE: En aquesta part es descargarn els events que te guardat el asset seleccionat. Com que tenim la variable date que ens diu el dia
                //en format DateTame només s'haurà de filtrar
              },
            ),
            const SizedBox(height: 8.0),
            Expanded(child: buildEventList(select)),
          ]);
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            print('hey');
            setState(() {
              print(events[0].userid);
            });
          }),
    );
  }
}

addEvent1(DateTime date, String name, Map<DateTime, List> events) {
DateTime dating = new DateTime.utc(date.year,date.month,date.day);
  if (events.containsKey(dating)) {
    events[dating].add(name);
  } else {
    events[dating] = [name];
  }
}*/