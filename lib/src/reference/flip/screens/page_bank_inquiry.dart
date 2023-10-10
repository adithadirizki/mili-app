import 'package:flutter/material.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/reference/flip/screens/bank_option.dart';
import 'package:miliv2/src/reference/flip/screens/inquiry.dart';

class PageBankInquiryFlip extends StatefulWidget {
  final List<Vendor> items;
  final Vendor? selectedVendor;
  final String? destination;

  const PageBankInquiryFlip({
    Key? key,
    required this.items,
    this.selectedVendor,
    this.destination,
  }) : super(key: key);

  @override
  _PageBankInquiryFlipState createState() => _PageBankInquiryFlipState();
}

class _PageBankInquiryFlipState extends State<PageBankInquiryFlip> {
  PageController _pageController = PageController(initialPage: 0);
  List<Widget> pageView = [];
  Vendor? _selectedVendor;
  String? _destination;

  @override
  void initState() {
    super.initState();

    _selectedVendor = widget.selectedVendor;
    _destination = widget.destination;

    initialPageView();
  }

  void initialPageView() {
    if (_selectedVendor == null) {
      pageView = [
        BankOptionFlip(
          items: widget.items,
          onVendorSelected: (value) {
            pageView.insert(1, InquiryScreenFlip(vendor: value));
            _pageController.jumpToPage(1);
          },
        ),
      ];
    } else {
      pageView = [
        BankOptionFlip(
          items: widget.items,
          onVendorSelected: (value) {
            pageView.insert(1, InquiryScreenFlip(vendor: value));
            _pageController.jumpToPage(1);
          },
        ),
        InquiryScreenFlip(
          vendor: _selectedVendor!,
          destination: _destination,
        ),
      ];
      _pageController = PageController(initialPage: 1);
    }

    // reset
    _selectedVendor = null;
    _destination = null;
  }

  Future<bool> onWillPop() async {
    if (_pageController.page! > 0) {
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
      initialPageView();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40),
      child: WillPopScope(
        onWillPop: onWillPop,
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: pageView,
        ),
      ),
    );
  }
}
