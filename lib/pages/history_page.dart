import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip History'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilterButton(label: 'All', isSelected: true),
                FilterButton(label: 'Completed', isSelected: false),
                FilterButton(label: 'Paid', isSelected: false),
                FilterButton(label: 'Canceled', isSelected: false),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                HistoryCard(
                  date: '21-12-2025',
                  tripId: '14',
                  from: 'Kigali, Nyarugenge KN 97 st',
                  to: 'Kimihurura, Gasabo KN 102 st',
                  time: '9:00',
                  distance: '450 m',
                  price: '400 RWF',
                  status: 'Completed',
                ),
                HistoryCard(
                  date: '20-12-2025',
                  tripId: '13',
                  from: 'Kigali, Nyarugenge KN 97 st',
                  to: 'South, Ruyenzi gare SN 1002 KN 97 st',
                  time: '11:00',
                  distance: '2 km',
                  price: '1000 RWF',
                  status: 'Completed',
                ),
                HistoryCard(
                  date: '19-12-2025',
                  tripId: '12',
                  from: 'Nyamagabe, Gasarenda',
                  to: 'Huye, Ngoma - Matyazo 1',
                  time: '15:00 PM',
                  distance: '50 km',
                  price: '1000 RWF',
                  status: 'Completed',
                ),
                HistoryCard(
                  date: '19-12-2025',
                  tripId: '11',
                  from: 'Kigali, Nyarugenge KN 97 st',
                  to: 'Kigali, Nyarugenge KN 97 st',
                  time: '12:00',
                  distance: '3.1 km',
                  price: '1000 RWF',
                  status: 'Completed',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;

  const FilterButton({super.key, required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.yellow : Colors.grey,
      ),
      child: Text(label),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final String date;
  final String tripId;
  final String from;
  final String to;
  final String time;
  final String distance;
  final String price;
  final String status;

  const HistoryCard({
    super.key,
    required this.date,
    required this.tripId,
    required this.from,
    required this.to,
    required this.time,
    required this.distance,
    required this.price,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trip Id: $tripId'),
                    Text('FROM: $from'),
                    Text('TO: $to'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(time),
                    Text(distance),
                    Text(price),
                    Text(status, style: TextStyle(color: Colors.green)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}