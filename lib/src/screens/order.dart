import 'package:flutter/material.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/order.dart';
import 'package:miliv2/src/widgets/order_data_table.dart';
import 'package:objectbox/objectbox.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Box<ShopOrder> _shopBox;
  late SyncClient _syncClient;
  bool hasBeenInitialized = false;

  int _totalOrder = 0;

  late Customer _customer;

  late Stream<List<ShopOrder>> _stream;

  @override
  void initState() {
    super.initState();
    setNewCustomer();
    _shopBox = AppDB.db.box<ShopOrder>();
    setState(() {
      _stream = _shopBox
          .query()
          .watch(triggerImmediately: true)
          .map((query) => query.find());
      hasBeenInitialized = true;
    });
  }

  void setNewCustomer() {
    _customer = Customer(name: 'My Customer');
  }

  void addFakeOrderForCurrentCustomer() {
    final order = ShopOrder(
      price: 100000,
    );
    order.customer.target = _customer;
    _shopBox.put(order);
  }

  @override
  void dispose() {
    // _syncClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders App ($_totalOrder)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt),
            onPressed: setNewCustomer,
          ),
          IconButton(
            icon: const Icon(Icons.attach_money),
            onPressed: addFakeOrderForCurrentCustomer,
          ),
        ],
      ),
      body: !hasBeenInitialized
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder<List<ShopOrder>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                _totalOrder = snapshot.data!.length;

                return OrderDataTable(
                  orders: snapshot.data!,
                  onSort: (columnIndex, ascending) {
                    final newQueryBuilder = _shopBox.query();
                    final sortField =
                        columnIndex == 0 ? ShopOrder_.id : ShopOrder_.price;
                    newQueryBuilder.order(
                      sortField,
                      flags: ascending ? 0 : Order.descending,
                    );

                    setState(() {
                      _stream = newQueryBuilder
                          .watch(triggerImmediately: true)
                          .map((query) => query.find());
                    });
                  },
                  box: _shopBox,
                );
              },
            ),
    );
  }
}
