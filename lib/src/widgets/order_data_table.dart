import 'package:flutter/material.dart';
import 'package:miliv2/src/models/order.dart';
import 'package:objectbox/objectbox.dart';

class OrderDataTable extends StatefulWidget {
  final List<ShopOrder> orders;
  final void Function(int columnIndex, bool ascending) onSort;
  final Box<ShopOrder> box;

  const OrderDataTable({
    Key? key,
    required this.orders,
    required this.onSort,
    required this.box,
  }) : super(key: key);

  @override
  _OrderDataTableState createState() => _OrderDataTableState();
}

class _OrderDataTableState extends State<OrderDataTable> {
  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: [
            DataColumn(
              label: Text('ID'),
              onSort: _onDataColumnSort,
            ),
            DataColumn(
              label: Text('Customer'),
            ),
            DataColumn(
              label: Text('Price'),
              numeric: true,
              onSort: _onDataColumnSort,
            ),
            DataColumn(
              label: Container(),
            ),
          ],
          rows: widget.orders.map(
            (order) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(order.id.toString()),
                  ),
                  DataCell(
                    Text(order.customer.target?.name ?? 'NONE'),
                    onTap: () {
                      showModalBottomSheet<Widget>(
                        context: context,
                        builder: (context) {
                          return Material(
                            child: ListView(
                              children: order.customer.target!.orders
                                  .map(
                                    (_) => ListTile(
                                      title: Text(
                                          '${_.id}    ${_.customer.target?.name}    \$${_.price}'),
                                    ),
                                  )
                                  .toList(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  DataCell(
                    Text(
                      '\$${order.price}',
                    ),
                  ),
                  DataCell(
                    Icon(Icons.delete),
                    onTap: () {
                      widget.box.remove(order.id);
                    },
                  ),
                ],
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  void _onDataColumnSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    widget.onSort(columnIndex, ascending);
  }
}
