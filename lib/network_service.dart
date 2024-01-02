import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkService {
  final String baseUrl = 'http://moetassemwehbe.x10.mx';

  Future<List<Map<String, dynamic>>> fetchItems() async {
    final response = await http.get(Uri.parse('$baseUrl/fetch_items.php'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load items');
    }
  }


  Future<void> placeOrder({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String location,
    required int guest,
    required int itemId,
    required double price,
    required double total_price,
    required int orderNotf,
    required int Quantity,
    required int categoryId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/insert_order.php'),
        body: {
          'first_name': firstName,
          'last_name': lastName,
          'date_of_birth': dateOfBirth.toString(),
          'location': location,
          'guest': guest.toString(),
          'item_id': itemId.toString(),
          'price':price.toString(),
          'total_price': price.toString(),
          'order_notf':orderNotf.toString(),
          'quantity':Quantity.toString(),
          'category_id': categoryId.toString()
        },
      );
      print(" "+response.body+" ");

      if (response.statusCode != 200) {
        throw Exception('Failed to place order');
      }
    } catch (error) {
      throw error;
    }
  }

}

