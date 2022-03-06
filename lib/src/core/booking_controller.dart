import 'package:booking_calendar/src/model/booking_service.dart';
import 'package:booking_calendar/src/util/booking_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookingController extends ChangeNotifier {
  BookingService bookingService;
  BookingController({required this.bookingService}) {
    serviceOpening = bookingService.bookingStart;
    serviceClosing = bookingService.bookingEnd;
    if (serviceOpening!.isAfter(serviceClosing!)) {
      throw "Service closing must be after opening";
    }
    base = serviceOpening!;
    _generateBookingSlots();
  }

  late DateTime base;

  DateTime? serviceOpening;
  DateTime? serviceClosing;

  List<DateTime> _allBookingSlots = [];
  List<DateTime> get allBookingSlots => _allBookingSlots;

  List<DateTimeRange> bookedSlots = [];

  int _selectedSlot = (-1);
  bool _isUploading = false;

  int get selectedSlot => _selectedSlot;
  bool get isUploading => _isUploading;


  bool _setOpeningDate(DateTime dateTime){
    try {
      serviceOpening =
          bookingService.bookingStarts.firstWhere((element) => element.year ==
              dateTime.year && element.month == dateTime.month &&
              element.day == dateTime.day);
      base = serviceOpening!;
      return true;
    } catch (e){
        print(e);
        return false;
    }
  }

  _setClosingDate(DateTime dateTime){
    try {
      serviceClosing = bookingService.bookingEnds.firstWhere((element) => element.year == dateTime.year && element.month == dateTime.month  && element.day == dateTime.day );
  } catch (e){
  print(e);
  }
  }

  void _generateBookingSlots() {
    int maxServiceFit = _maxServiceFitInADay();
    allBookingSlots.clear();
    _allBookingSlots = List.generate(
        maxServiceFit,
        (index) => base
            .add(Duration(minutes: bookingService.serviceDuration) * index));
    _allBookingSlots.removeWhere((element) => DateTime.now().isAfter(element));

  }

  int _maxServiceFitInADay() {
   if (!_setOpeningDate(base)) return 0;
    _setClosingDate(base);
    ///if no serviceOpening and closing was provided we will calculate with 00:00-24:00
    int openingHours = 24;
    if (serviceOpening != null && serviceClosing != null) {
      openingHours = DateTimeRange(start: serviceOpening!, end: serviceClosing!)
          .duration
          .inHours;
    }

    ///round down if not the whole service would fit in the last hours
    return ((openingHours * 60) / bookingService.serviceDuration).floor();
  }

  bool isSlotBooked(int index) {
    DateTime checkSlot = allBookingSlots.elementAt(index);
    bool result = false;
    for (var slot in bookedSlots) {
      if (BookingUtil.isOverLapping(slot.start, slot.end, checkSlot,
          checkSlot.add(Duration(minutes: bookingService.serviceDuration)))) {
        result = true;
        break;
      }
    }
    return result;
  }

  void selectSlot(int idx) {
    _selectedSlot = idx;
    notifyListeners();
  }

  void resetSelectedSlot() {
    _selectedSlot = -1;
    notifyListeners();
  }

  void toggleUploading() {
    _isUploading = !_isUploading;
    notifyListeners();
  }

  Future<void> generateBookedSlots(List<DateTimeRange> data) async {
    bookedSlots.clear();
    _generateBookingSlots();

    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      bookedSlots.add(item);
    }
  }

  BookingService generateNewBookingForUploading() {
    final bookingDate = allBookingSlots.elementAt(selectedSlot);
    bookingService
      ..bookingStart = (bookingDate)
      ..bookingEnd =
          (bookingDate.add(Duration(minutes: bookingService.serviceDuration)));
    return bookingService;
  }
}
