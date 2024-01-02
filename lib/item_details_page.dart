import 'dart:typed_data';
import 'network_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemDetailsPage extends StatefulWidget {
  final int itemId;
  final String itemName;
  final String description;
  final int Quantity;
  final int categoryId;
  final double price;
  final Uint8List imageBytes;
  final NetworkService networkService;

  const ItemDetailsPage({
    required this.itemId,
    required this.itemName,
    required this.description,
    required this.Quantity,
    required this.categoryId,
    required this.price,
    required this.imageBytes,
    required this.networkService,
  });

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? firstName;
  String? lastName;
  DateTime? dateOfBirth;
  String? location;

  void _showSuccessMessage(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('Order placed successfully!'),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemName),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width,
              child: Image.memory(
                widget.imageBytes,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.itemName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              '\$ ${widget.price.toString()}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'First Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                    onSaved: (value) => firstName = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Last Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                    onSaved: (value) => lastName = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Location'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your location';
                      }
                      return null;
                    },
                    onSaved: (value) => location = value,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: widget.Quantity > 0 ? () async {
                      setState(() {
                        isLoading = true;
                      });

                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        try {
                          await widget.networkService.placeOrder(
                          firstName: firstName!,
                          lastName: lastName ?? '',
                          dateOfBirth:dateOfBirth = DateTime(2000, 12, 31),
                          location: location!,
                          guest: 1,
                          itemId: widget.itemId,
                          Quantity:widget.Quantity,
                          price:widget.price,
                          total_price:widget.price,
                          categoryId: widget.categoryId,
                          orderNotf: 1
                        );_showSuccessMessage(context);
                          await Future.delayed(Duration(seconds: 2));
                          Navigator.of(context).pop();
                        } catch (error) {
                          print('Error: $error');
                        }
                      }
                    } : null,
                    child: isLoading ? CircularProgressIndicator() :
                    widget.Quantity > 0 ? Text('Order') : Text('Item Out of Stock'),
                  )
              ],
          ),
        ),
          ],
        ),
      ),
    );
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != dateOfBirth) {
      setState(() {
        dateOfBirth = picked;
      });
    }
  }

}