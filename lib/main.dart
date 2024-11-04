import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Model for the candidate information
class ExampleCandidateModel {
  final String title;
  final String explanation;
  final String url;
  final String hdurl;
  final String date;
  final String copyright;

  ExampleCandidateModel({
    required this.title,
    required this.explanation,
    required this.url,
    required this.hdurl,
    required this.date,
    required this.copyright,
  });

  factory ExampleCandidateModel.fromJson(Map<String, dynamic> json) {
    return ExampleCandidateModel(
      title: json['title'] ?? 'Unknown Title',
      explanation: json['explanation'] ?? 'No explanation available',
      url: json['url'] ?? 'Image Not Found',
      hdurl: json['hdurl'] ?? 'Image Not Found',
      date: json['date'] ?? 'Unknown Date',
      copyright: json['copyright'] ?? '',
    );
  }
}

// Function to fetch space information
Future<List<ExampleCandidateModel>> fetchSpaceInfo() async {
  final response = await http.get(Uri.parse(
      "https://api.nasa.gov/planetary/apod?api_key=l6PhtenfV5dvA0VaUMipFBkqgmqjfKPVxb3h05xt&count=10"));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => ExampleCandidateModel.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

// Widget to display candidate information in a card
class ExampleCard extends StatelessWidget {
  final ExampleCandidateModel candidate;

  const ExampleCard(this.candidate, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (candidate.url.isNotEmpty)
            Container(
              height: 550,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(candidate.url),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 150,
              color: Colors.grey,
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.title,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Source: NASA",
                  style: TextStyle(color: Colors.grey),
                ),

                // Text(
                //   candidate.explanation,
                //   style: TextStyle(
                //     color: Colors.grey,
                //     fontSize: 15,
                //   ),
                // ),
                // SizedBox(height: 5),
                // Text(
                //   candidate.date,
                //   style: TextStyle(color: Colors.grey),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Main application widget
class Example extends StatefulWidget {
  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<Example> {
  final CardSwiperController controller = CardSwiperController();
  List<ExampleCandidateModel> candidates = [];

  @override
  void initState() {
    super.initState();
    fetchSpaceInfo().then((data) {
      setState(() {
        candidates = data;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Space',
            style: TextStyle(
              color: Colors.white, // Set the title color here
            ),
          ),
          backgroundColor: Colors.blue),
      body: SafeArea(
        child: candidates.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Flexible(
                    child: CardSwiper(
                      controller: controller,
                      cardsCount: candidates.length,
                      onSwipe: _onSwipe,
                      onUndo: _onUndo,
                      numberOfCardsDisplayed: 5,
                      backCardOffset: const Offset(40, 40),
                      padding: const EdgeInsets.all(16.0),
                      cardBuilder: (context,
                          index,
                          horizontalThresholdPercentage,
                          verticalThresholdPercentage) {
                        return ExampleCard(candidates[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      // children: [
                      //   FloatingActionButton(
                      //     onPressed: controller.undo,
                      //     child: const Icon(Icons.rotate_left),
                      //   ),
                      //   FloatingActionButton(
                      //     onPressed: () =>
                      //         controller.swipe(CardSwiperDirection.left),
                      //     child: const Icon(Icons.keyboard_arrow_left),
                      //   ),
                      //   FloatingActionButton(
                      //     onPressed: () =>
                      //         controller.swipe(CardSwiperDirection.right),
                      //     child: const Icon(Icons.keyboard_arrow_right),
                      //   ),
                      //   FloatingActionButton(
                      //     onPressed: () =>
                      //         controller.swipe(CardSwiperDirection.top),
                      //     child: const Icon(Icons.keyboard_arrow_up),
                      //   ),
                      //   FloatingActionButton(
                      //     onPressed: () =>
                      //         controller.swipe(CardSwiperDirection.bottom),
                      //     child: const Icon(Icons.keyboard_arrow_down),
                      //   ),
                      // ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint(
      'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
    );
    return true;
  }

  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint(
      'The card $currentIndex was undone from the ${direction.name}',
    );
    return true;
  }
}

// Entry point of the application
void main() {
  runApp(MaterialApp(
    title: 'Space',
    home: Example(),
    debugShowCheckedModeBanner: false, // Disable the debug banner
  ));
}
