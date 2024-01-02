import 'package:flutter/material.dart';
import 'network_service.dart';
import 'item_details_page.dart';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NetworkService networkService = NetworkService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> allItems = [];
  List<dynamic> displayedItems = [];
  String selectedCategory = 'All';
  String selectedSortOption = 'Default';

  void filterItems(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'All') {
        displayedItems = List.from(allItems);
      } else {
        displayedItems = allItems.where((item) {
          return item['category_id'].toString() == category;
        }).toList();
      }
      sortDisplayedItems();
    });
  }

  void sortItems(String sortOption) {
    setState(() {
      selectedSortOption = sortOption;
      sortDisplayedItems();
    });
  }

  void sortDisplayedItems() {
    switch (selectedSortOption) {
      case 'AtoZ':
        displayedItems.sort((a, b) => a['item_name'].compareTo(b['item_name']));
        break;
      case 'ZtoA':
        displayedItems.sort((a, b) => b['item_name'].compareTo(a['item_name']));
        break;
      case 'HighToLow':
        displayedItems.sort((a, b) => b['price'].compareTo(a['price']));
        break;
      case 'LowToHigh':
        displayedItems.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      default:
      // Default sorting (as received from the API)
        break;
    }
  }

  Map<String, String> categories = {
    'All': 'All',
    '1': 'Phones',
    '2': 'Accessories',
  };

  Map<String, String> sortOptions = {
    'Default': 'Default',
    'AtoZ': 'A to Z',
    'ZtoA': 'Z to A',
    'HighToLow': 'High to Low',
    'LowToHigh': 'Low to High',
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item Display App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Items'),
          backgroundColor: Colors.black,

        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      filterItems(newValue!);
                    },
                    items: categories.entries.map<DropdownMenuItem<String>>(
                          (entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      },
                    ).toList(),
                  ),
                  DropdownButton<String>(
                    value: selectedSortOption,
                    onChanged: (String? newValue) {
                      sortItems(newValue!);
                    },
                    items: sortOptions.entries.map<DropdownMenuItem<String>>(
                          (entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: networkService.fetchItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    allItems = snapshot.data ?? [];
                    displayedItems = List.from(allItems);
                    sortDisplayedItems();

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: displayedItems.length,
                      itemBuilder: (context, index) {
                        var item = displayedItems[index];
                        String base64Image = item['image'];
                        Uint8List imageBytes = base64.decode(base64Image);

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ItemDetailsPage(
                                  itemId: int.parse(item['item_id']),
                                  itemName: item['item_name'],
                                  description: item['description'],
                                  Quantity: int.parse(item['quantity'].toString()),
                                  price: double.parse(item['price'].toString()),
                                  imageBytes: imageBytes,
                                  categoryId: int.parse(item['category_id'].toString()),
                                  networkService: NetworkService(),
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.memory(
                                        imageBytes,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    item['item_name'],
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
