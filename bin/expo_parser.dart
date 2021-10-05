import 'dart:convert';
import 'dart:io' as io;

import 'package:universal_html/html.dart';
import 'package:universal_html/parsing.dart';
import 'package:universal_html/controller.dart';

const String baseExpoUrl = "www.expo2020dubai.com";

void main(List<String> arguments) async {
  final controller = WindowController();
  await controller.openUri(Uri.parse("https://www.expo2020dubai.com/en/understanding-expo/participants/country-pavilions"));
  
  // The above URL will have a <ul> in which each item, from class `search__results-item`
  // will have as a value a country pavilion
  final pavillionsLiElements = controller.window?.document?.querySelectorAll("li.search__results-item") ?? [];
  final pavillions = <Map<String, String>>[];

  for (LIElement listItem in pavillionsLiElements) {
    final aElement = listItem.children.first as AnchorElement;

    // All countries will have " Pavilion" at the end, eg. "Portugal Pavilion",
    // so we must trim the string, and remove that.
    final country = (aElement.text)?.split(" Pavilion")?.first ?? "";

    // The href for each item will be relative, eg.: "en/understanding-expo/participants/country-pavilions/uk"
    // and [WindowController] will add `http://localhost` as the baseUrl for all relative URLs
    // which means we must remove the base url
    final url = Uri.parse(aElement.href ?? "").replace(scheme: "https", host:  baseExpoUrl);
    pavillions.add(<String, String> {
      "country": country,
      "url" : url.toString(),
    });
  }

  // `recursive` will create all the missing files and folders
  final output = await io.File("output/countries.json").create(recursive: true);
  await output.writeAsString(jsonEncode(pavillions));
}
