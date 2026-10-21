import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  Locale _locale = const Locale('en');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _AppScrollBehavior(),
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('id')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'wheel_choice_ext demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: _HomePage(
        currentLocale: _locale,
        onLocaleChanged: (loc) => setState(() => _locale = loc),
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage({
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wheel Choice Ext Showcase'),
        actions: [
          Row(
            children: [
              const Icon(Icons.language, size: 20),
              const SizedBox(width: 6),
              DropdownButton<Locale>(
                value: widget.currentLocale,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('EN')),
                  DropdownMenuItem(value: Locale('id'), child: Text('ID')),
                ],
                onChanged: (loc) {
                  if (loc != null) widget.onLocaleChanged(loc);
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: 'Date Picker'),
            Tab(icon: Icon(Icons.access_time), text: 'Time Picker'),
            Tab(icon: Icon(Icons.palette), text: 'Subtree Theming'),
            Tab(icon: Icon(Icons.edit_calendar), text: 'Form Integration'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DatePickerTab(),
          _TimePickerTab(),
          _ThemingTab(),
          _FormTab(),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 1: DATE PICKER DEMO
// -----------------------------------------------------------------------------
class _DatePickerTab extends StatefulWidget {
  const _DatePickerTab();

  @override
  State<_DatePickerTab> createState() => _DatePickerTabState();
}

class _DatePickerTabState extends State<_DatePickerTab> {
  late final WheelDateController _dateCtrl;
  WheelDateOrder? _order;

  @override
  void initState() {
    super.initState();
    _dateCtrl = WheelDateController(value: DateTime.now());
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            children: [
              // Order selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Date Order:'),
                  DropdownButton<String>(
                    value: _order == null
                        ? 'locale'
                        : (_order == WheelDateOrder.mdy
                            ? 'mdy'
                            : _order == WheelDateOrder.ymd
                                ? 'ymd'
                                : 'dmy'),
                    items: const [
                      DropdownMenuItem(value: 'locale', child: Text('Locale-aware')),
                      DropdownMenuItem(value: 'dmy', child: Text('Day-Month-Year')),
                      DropdownMenuItem(value: 'mdy', child: Text('Month-Day-Year')),
                      DropdownMenuItem(value: 'ymd', child: Text('Year-Month-Day')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        switch (val) {
                          case 'dmy':
                            _order = WheelDateOrder.dmy;
                            break;
                          case 'mdy':
                            _order = WheelDateOrder.mdy;
                            break;
                          case 'ymd':
                            _order = WheelDateOrder.ymd;
                            break;
                          default:
                            _order = null;
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  child: WheelDateChoice.raw(
                    controller: _dateCtrl,
                    itemExtent: 44,
                    itemVisible: 5,
                    spacing: 8,
                    order: _order,
                    overlay: WheelOverlay.outlined(borderColor: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Stepper controls
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _dateCtrl.previousDay(),
                    icon: const Icon(Icons.remove, size: 16),
                    label: const Text('Day'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _dateCtrl.nextDay(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Day'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _dateCtrl.previousMonth(),
                    icon: const Icon(Icons.remove, size: 16),
                    label: const Text('Month'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _dateCtrl.nextMonth(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Month'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Reactive Display
              ValueListenableBuilder<DateTime>(
                valueListenable: _dateCtrl.valueListenable,
                builder: (context, date, _) {
                  return Text(
                    'Selected Date: ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 2: TIME PICKER DEMO
// -----------------------------------------------------------------------------
class _TimePickerTab extends StatefulWidget {
  const _TimePickerTab();

  @override
  State<_TimePickerTab> createState() => _TimePickerTabState();
}

class _TimePickerTabState extends State<_TimePickerTab> {
  bool _use24h = false;
  int _minuteStep = 5;
  late WheelTimeController _timeCtrl;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _timeCtrl = WheelTimeController(
      value: const TimeOfDay(hour: 14, minute: 30),
      use24hFormat: _use24h,
      minuteStep: _minuteStep,
    );
  }

  void _recreateController() {
    final oldTime = _timeCtrl.value;
    _timeCtrl.dispose();
    _timeCtrl = WheelTimeController(
      value: oldTime,
      use24hFormat: _use24h,
      minuteStep: _minuteStep,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _timeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('24-Hour Format:'),
                  Switch(
                    value: _use24h,
                    onChanged: (val) {
                      _use24h = val;
                      _recreateController();
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Minute Interval:'),
                  DropdownButton<int>(
                    value: _minuteStep,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 min')),
                      DropdownMenuItem(value: 5, child: Text('5 min')),
                      DropdownMenuItem(value: 15, child: Text('15 min')),
                    ],
                    onChanged: (s) {
                      if (s != null) {
                        _minuteStep = s;
                        _recreateController();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  child: WheelTimeChoice.raw(
                    key: ValueKey('time_${_use24h}_$_minuteStep'),
                    controller: _timeCtrl,
                    itemExtent: 44,
                    itemVisible: 5,
                    spacing: 8,
                    overlay: WheelOverlay.outlined(borderColor: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _timeCtrl.previousHour(),
                    icon: const Icon(Icons.remove, size: 16),
                    label: const Text('Hour'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _timeCtrl.nextHour(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Hour'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _timeCtrl.previousMinute(),
                    icon: const Icon(Icons.remove, size: 16),
                    label: const Text('Minute'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _timeCtrl.nextMinute(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Minute'),
                  ),
                  if (!_use24h)
                    OutlinedButton.icon(
                      onPressed: () => _timeCtrl.togglePeriod(),
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('AM/PM'),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              ValueListenableBuilder<TimeOfDay>(
                valueListenable: _timeCtrl.valueListenable,
                builder: (context, time, _) {
                  return Text(
                    'Selected Time: ${time.format(context)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 3: SUBTREE THEMING DEMO
// -----------------------------------------------------------------------------
class _ThemingTab extends StatelessWidget {
  const _ThemingTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Subtree Theming with WheelChoiceTheme',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Demonstrates how both Date and Time pickers effortlessly inherit custom itemExtent, 3D magnification effect, and overlays from a single ancestor theme.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Ancestor WheelChoiceTheme
              WheelChoiceTheme(
                data: WheelChoiceThemeData(
                  itemExtent: 48,
                  itemVisible: 5,
                  effect: const WheelEffect(
                    useMagnifier: true,
                    magnification: 1.15,
                    perspective: 0.007,
                  ),
                  overlay: WheelOverlay.filled(
                    color: Colors.purple.withAlpha(35),
                  ),
                ),
                child: Column(
                  children: [
                    Card(
                      elevation: 0,
                      color: Colors.purple.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: WheelDateChoice(
                          value: DateTime(2025, 10, 21),
                          spacing: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      color: Colors.purple.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: const WheelTimeChoice(
                          value: TimeOfDay(hour: 18, minute: 45),
                          use24hFormat: false,
                          spacing: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 4: FORM FIELD INTEGRATION DEMO
// -----------------------------------------------------------------------------
class _FormTab extends StatefulWidget {
  const _FormTab();

  @override
  State<_FormTab> createState() => _FormTabState();
}

class _FormTabState extends State<_FormTab> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _bookedDate = DateTime.now();
  TimeOfDay? _bookedTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Appointment Booking Form',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Demonstrates WheelDateChoiceFormField and WheelTimeChoiceFormField with automatic validation, decoration, and reset support.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                WheelDateChoiceFormField(
                  initialValue: _bookedDate,
                  decoration: const InputDecoration(
                    labelText: 'Appointment Date',
                    border: OutlineInputBorder(),
                    helperText: 'Must be on a weekday (Mon-Fri)',
                  ),
                  validator: (d) {
                    if (d == null) return 'Please choose a date';
                    if (d.weekday == DateTime.saturday || d.weekday == DateTime.sunday) {
                      return 'Clinics are closed on weekends! Please select Mon-Fri.';
                    }
                    return null;
                  },
                  onSaved: (d) => _bookedDate = d,
                ),

                const SizedBox(height: 24),

                WheelTimeChoiceFormField(
                  initialValue: _bookedTime,
                  use24hFormat: false,
                  minuteStep: 15,
                  decoration: const InputDecoration(
                    labelText: 'Appointment Time',
                    border: OutlineInputBorder(),
                    helperText: 'Working hours: 09:00 AM - 05:00 PM',
                  ),
                  validator: (t) {
                    if (t == null) return 'Please choose a time';
                    if (t.hour < 9 || t.hour >= 17) {
                      return 'Appointments must be between 9:00 AM and 5:00 PM';
                    }
                    return null;
                  },
                  onSaved: (t) => _bookedTime = t,
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _formKey.currentState!.reset();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Form reset to initial values')),
                          );
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Appointment booked for ${_bookedDate!.year}-${_bookedDate!.month}-${_bookedDate!.day} at ${_bookedTime!.format(context)}',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Confirm Booking'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
