import 'package:example/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:booking_calendar/booking_calendar.dart';

void main() {
  runApp(const BookingCalendarDemoApp());
}

class BookingCalendarDemoApp extends StatefulWidget {
  const BookingCalendarDemoApp({Key? key}) : super(key: key);

  @override
  State<BookingCalendarDemoApp> createState() => _BookingCalendarDemoAppState();
}

class _BookingCalendarDemoAppState extends State<BookingCalendarDemoApp> {
  final now = DateTime.now();
  late BookingService mockBookingService;

  @override
  void initState() {
    super.initState();
    // DateTime.now().startOfDay
    // DateTime.now().endOfDay
    List<DateTime> test = [];
    List<DateTime> test2 = [];
    List<DateTimeRange> restTimesList = [];
    test.add(DateTime(now.year, now.month, now.day, 23, 30));
    test2.add(DateTime(now.year, now.month, now.day, 0, 30));
    test.add(DateTime(now.year, now.month, now.day, 23, 30).add(Duration(days: 1)));
    test2.add(DateTime(now.year, now.month, now.day, 8, 30).add(Duration(days: 1)));
    restTimesList.add(DateTimeRange(start:DateTime(now.year, now.month, now.day, 8, 30).add(Duration(days: 1)), end: DateTime(now.year, now.month, now.day, 15, 30).add(Duration(days: 1))));

    Map<DateTime, List<DateTimeRange>> restTimes = {DateTime(now.year, now.month, now.day, 8, 30).add(Duration(days: 1)):restTimesList};

    mockBookingService = BookingService(
      restTimes: restTimes,
        serviceName: 'Mock Service',
        serviceDuration: 30,
        bookingStarts: test2,
        bookingEnds: test,
        bookingEnd: DateTime(now.year, now.month, now.day, 18, 0),
        bookingStart: DateTime(now.year, now.month, now.day, 8, 0));
  }

  Stream<dynamic>? getBookingStreamMock(
      {required DateTime end, required DateTime start}) {
    return Stream.value([]);
  }

  Future<dynamic> uploadBookingMock(
      {required BookingService newBooking}) async {
    await Future.delayed(const Duration(seconds: 1));
    converted.add(DateTimeRange(
        start: newBooking.bookingStart, end: newBooking.bookingEnd));
    print('${newBooking.toJson()} has been uploaded');
  }

  List<DateTimeRange> converted = [];

  List<DateTimeRange> convertStreamResultMock({required dynamic streamResult}) {
    ///here you can parse the streamresult and convert to [List<DateTimeRange>]
    DateTime first = now;
    DateTime second = now.add(Duration(minutes: 55));
    DateTime third = now.subtract(Duration(minutes: 240));
    DateTime fourth = now.subtract(Duration(minutes: 500));
    converted
        .add(DateTimeRange(start: first, end: now.add(Duration(minutes: 30))));
    converted.add(
        DateTimeRange(start: second, end: second.add(Duration(minutes: 23))));
    converted.add(
        DateTimeRange(start: third, end: third.add(Duration(minutes: 15))));
    converted.add(
        DateTimeRange(start: fourth, end: fourth.add(Duration(minutes: 50))));
    return converted;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Booking Calendar Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Booking Calendar Demo'),
          ),
          body: Center(
            child: BookingCalendar(
              bookingService: mockBookingService,
              convertStreamResultToDateTimeRanges: convertStreamResultMock,
              getBookingStream: getBookingStreamMock,
              uploadBooking: uploadBookingMock,
              selectedSlotColor: Colors.black12,
              availableSlotColor: Colors.white,
              bookedSlotColor: Colors.white.withOpacity(0.3),
              bookingButtonColor: Colors.blue,
            ),
          ),
        ));
  }
}
