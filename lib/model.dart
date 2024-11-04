import 'package:flutter/material.dart'; // Import Color
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<ExampleCandidateModel>> fetchSpaceInfo() async {
  final response = await getSpaceInfo();

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => ExampleCandidateModel.fromJson(item)).toList();
  } else {
    return []; // Return an empty list on error
  }
}

Future<http.Response> getSpaceInfo() {
  var url =
      "https://api.nasa.gov/planetary/apod?api_key=l6PhtenfV5dvA0VaUMipFBkqgmqjfKPVxb3h05xt&count=10";
  // Replace with your actual API endpoint
  return http.get(Uri.parse(url));
}

// The fetchSpaceInfo function should be awaited, so we can initialize candidates properly
Future<List<ExampleCandidateModel>> initializeCandidates() async {
  return await fetchSpaceInfo();
}

class ExampleCandidateModel {
  final String name;
  final String job;
  final String city;
  final List<Color> color;

  ExampleCandidateModel({
    required this.name,
    required this.job,
    required this.city,
    required this.color,
  });

  // Factory constructor to create a User from JSON
  factory ExampleCandidateModel.fromJson(Map<String, dynamic> json) {
    return ExampleCandidateModel(
      city: json['explanation'],
      name: json['title'],
      job: json['copyright'],
      color: const [Color(0xFFFF3868), Color(0xFFFFB49A)],
    );
  }
}

// Initialize candidates when the app starts
Future<List<ExampleCandidateModel>> candidatesFuture = initializeCandidates();
