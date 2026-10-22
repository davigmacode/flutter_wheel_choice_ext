import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      title: 'Wheel Choice Ext Showcase',
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
    _tabController = TabController(length: 6, vsync: this);
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
        title: const Text('Wheel Choice Ext Suite'),
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
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: 'Date & Time'),
            Tab(icon: Icon(Icons.timer_outlined), text: 'Duration'),
            Tab(icon: Icon(Icons.numbers), text: 'Number / Weight'),
            Tab(icon: Icon(Icons.date_range), text: 'Date Range'),
            Tab(icon: Icon(Icons.account_tree_outlined), text: 'Cascade'),
            Tab(icon: Icon(Icons.open_in_new), text: 'Dialogs & Sheets'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DateTimeTab(),
          _DurationTab(),
          _NumberTab(),
          _RangeTab(),
          _CascadeTab(),
          _DialogsTab(),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 1: DATE & TIME COMBINED
// -----------------------------------------------------------------------------
class _DateTimeTab extends StatefulWidget {
  const _DateTimeTab();

  @override
  State<_DateTimeTab> createState() => _DateTimeTabState();
}

class _DateTimeTabState extends State<_DateTimeTab> {
  late final WheelDateController _dateController;
  late WheelTimeController _timeController;
  late WheelDateTimeController _dateTimeController;

  bool _use24hTime = true;
  bool _use24hDateTime = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController = WheelDateController(value: now);
    _timeController = WheelTimeController(
      value: TimeOfDay.fromDateTime(now),
      use24hFormat: _use24hTime,
    );
    _dateTimeController = WheelDateTimeController(
      value: now,
      use24hFormat: _use24hDateTime,
      minuteStep: 5,
    );
  }

  void _setTimeMode(bool use24h) {
    if (_use24hTime == use24h) return;
    setState(() {
      _use24hTime = use24h;
      final current = _timeController.value;
      _timeController.dispose();
      _timeController = WheelTimeController(
        value: current,
        use24hFormat: _use24hTime,
      );
    });
  }

  void _setDateTimeMode(bool use24h) {
    if (_use24hDateTime == use24h) return;
    setState(() {
      _use24hDateTime = use24h;
      final current = _dateTimeController.value;
      _dateTimeController.dispose();
      _dateTimeController = WheelDateTimeController(
        value: current,
        use24hFormat: _use24hDateTime,
        minuteStep: 5,
      );
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              // 1. DATE ONLY
              _ExampleCard(
                title: 'WheelDateChoice (Date Only)',
                description: 'Day, Month, and Year wheels with automatic leap-year clamping.',
                picker: Card(
                  elevation: 0,
                  color: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    child: WheelDateChoice.raw(
                      controller: _dateController,
                      itemExtent: 44,
                      itemVisible: 5,
                      spacing: 12,
                      header: const WheelDateHeader(
                        day: WheelHeader(child: Text('Day')),
                        month: WheelHeader(child: Text('Month')),
                        year: WheelHeader(child: Text('Year')),
                      ),
                      overlay: WheelOverlay.outlined(borderColor: primaryColor),
                    ),
                  ),
                ),
                result: ValueListenableBuilder<DateTime>(
                  valueListenable: _dateController.valueListenable,
                  builder: (context, d, _) {
                    return Text(
                      'Selected Date: ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                    );
                  },
                ),
                code: '''// Date Only Wheel Picker
WheelDateChoice(
  value: DateTime.now(),
  itemExtent: 44,
  itemVisible: 5,
  spacing: 12,
  header: const WheelDateHeader(
    day: WheelHeader(child: Text('Day')),
    month: WheelHeader(child: Text('Month')),
    year: WheelHeader(child: Text('Year')),
  ),
  overlay: WheelOverlay.outlined(),
  onChanged: (DateTime date) {
    print('Picked Date: \$date');
  },
)''',
              ),
              const SizedBox(height: 36),
              const Divider(),
              const SizedBox(height: 36),

              // 2. TIME ONLY
              _ExampleCard(
                title: 'WheelTimeChoice (Time Only)',
                description: 'Supports both 24-hour (00..23) and 12-hour (01..12 + AM/PM) modes.',
                controls: Center(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        label: Text('24 Hours'),
                        icon: Icon(Icons.schedule),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text('12 Hours (AM/PM)'),
                        icon: Icon(Icons.access_time),
                      ),
                    ],
                    selected: {_use24hTime},
                    onSelectionChanged: (val) => _setTimeMode(val.first),
                  ),
                ),
                picker: Card(
                  elevation: 0,
                  color: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    child: WheelTimeChoice.raw(
                      key: ValueKey(_use24hTime),
                      controller: _timeController,
                      itemExtent: 44,
                      itemVisible: 5,
                      spacing: 12,
                      header: WheelTimeHeader(
                        hour: const WheelHeader(child: Text('Hour')),
                        minute: const WheelHeader(child: Text('Minute')),
                        period: _use24hTime ? null : const WheelHeader(child: Text('Period')),
                      ),
                      overlay: WheelOverlay.outlined(borderColor: primaryColor),
                    ),
                  ),
                ),
                result: ValueListenableBuilder<TimeOfDay>(
                  valueListenable: _timeController.valueListenable,
                  builder: (context, t, _) {
                    return Text(
                      'Selected Time: ${t.format(context)} (${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                    );
                  },
                ),
                code: '''// Time Picker in ${_use24hTime ? '24-hour mode (2 columns: 00..23 & 00..59)' : '12-hour mode (3 columns: 01..12, 00..59, & AM/PM)'}
WheelTimeChoice(
  value: TimeOfDay.now(),
  use24hFormat: $_use24hTime,
  itemExtent: 44,
  itemVisible: 5,
  spacing: 12,
  header: const WheelTimeHeader(
    hour: WheelHeader(child: Text('Hour')),
    minute: WheelHeader(child: Text('Minute')),${_use24hTime ? '' : "\n    period: WheelHeader(child: Text('Period')),"}
  ),
  overlay: WheelOverlay.outlined(),
  onChanged: (TimeOfDay time) {
    print('Picked Time: \$time');
  },
)''',
              ),
              const SizedBox(height: 36),
              const Divider(),
              const SizedBox(height: 36),

              // 3. COMBINED DATE & TIME
              _ExampleCard(
                title: 'WheelDateTimeChoice (Combined Date & Time)',
                description: 'Synchronized calendar date and time wheels in one composite picker.',
                controls: Center(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        label: Text('24 Hours'),
                        icon: Icon(Icons.schedule),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text('12 Hours'),
                        icon: Icon(Icons.access_time),
                      ),
                    ],
                    selected: {_use24hDateTime},
                    onSelectionChanged: (val) => _setDateTimeMode(val.first),
                  ),
                ),
                picker: Card(
                  elevation: 0,
                  color: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    child: WheelDateTimeChoice.raw(
                      key: ValueKey(_use24hDateTime),
                      controller: _dateTimeController,
                      itemExtent: 44,
                      itemVisible: 5,
                      spacing: 6,
                      overlay: WheelOverlay.outlined(borderColor: primaryColor),
                    ),
                  ),
                ),
                result: ValueListenableBuilder<DateTime>(
                  valueListenable: _dateTimeController.valueListenable,
                  builder: (context, dt, _) {
                    return Text(
                      'Selected: ${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${TimeOfDay.fromDateTime(dt).format(context)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                    );
                  },
                ),
                code: '''// Combined Date & Time (${_use24hDateTime ? '24h' : '12h'} format)
WheelDateTimeChoice(
  value: DateTime.now(),
  use24hFormat: $_use24hDateTime,
  minuteStep: 5,
  itemExtent: 44,
  itemVisible: 5,
  spacing: 6,
  overlay: WheelOverlay.outlined(),
  onChanged: (DateTime dt) {
    print('Picked DateTime: \$dt');
  },
)''',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 2: DURATION / TIMER
// -----------------------------------------------------------------------------
class _DurationTab extends StatefulWidget {
  const _DurationTab();

  @override
  State<_DurationTab> createState() => _DurationTabState();
}

class _DurationTabState extends State<_DurationTab> {
  late final WheelDurationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WheelDurationController(
      value: const Duration(hours: 1, minutes: 30, seconds: 0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _ExampleCard(
            title: 'WheelDurationChoice (Timer & Duration)',
            description: 'Customizable hours, minutes, and seconds duration selector.',
            picker: Card(
              elevation: 0,
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: WheelDurationChoice.raw(
                  controller: _controller,
                  itemExtent: 44,
                  itemVisible: 5,
                  spacing: 12,
                  itemLabel: WheelDurationLabel.suffix(),
                  header: const WheelDurationHeader(
                    hours: WheelHeader(child: Text('Hours')),
                    minutes: WheelHeader(child: Text('Mins')),
                    seconds: WheelHeader(child: Text('Secs')),
                  ),
                  overlay: WheelOverlay.outlined(borderColor: primaryColor),
                ),
              ),
            ),
            result: ValueListenableBuilder<Duration>(
              valueListenable: _controller.valueListenable,
              builder: (context, dur, _) {
                final h = dur.inHours.toString().padLeft(2, '0');
                final m = (dur.inMinutes % 60).toString().padLeft(2, '0');
                final s = (dur.inSeconds % 60).toString().padLeft(2, '0');
                return Text(
                  'Duration: $h:$m:$s (${dur.inMinutes} total minutes)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                );
              },
            ),
            code: '''// Duration / Countdown Wheel
WheelDurationChoice(
  value: const Duration(hours: 1, minutes: 30, seconds: 0),
  itemExtent: 44,
  itemVisible: 5,
  spacing: 12,
  itemLabel: WheelDurationLabel.suffix(),
  header: const WheelDurationHeader(
    hours: WheelHeader(child: Text('Hours')),
    minutes: WheelHeader(child: Text('Mins')),
    seconds: WheelHeader(child: Text('Secs')),
  ),
  overlay: WheelOverlay.outlined(),
  onChanged: (Duration d) {
    print('Picked Duration: \$d');
  },
)''',
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 3: NUMBER & WEIGHT/HEIGHT
// -----------------------------------------------------------------------------
class _NumberTab extends StatefulWidget {
  const _NumberTab();

  @override
  State<_NumberTab> createState() => _NumberTabState();
}

class _NumberTabState extends State<_NumberTab> {
  late final WheelNumberController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WheelNumberController(
      value: 68.5,
      min: 30,
      max: 200,
      precision: 1,
      units: const ['kg', 'lbs'],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _ExampleCard(
            title: 'WheelNumberChoice (Integer + Decimal + Unit)',
            description: 'Decimal numbers with selectable unit column (weight, length, etc.).',
            picker: Card(
              elevation: 0,
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: WheelNumberChoice.raw(
                  controller: _controller,
                  itemExtent: 44,
                  itemVisible: 5,
                  spacing: 8,
                  header: const WheelNumberHeader(
                    integer: WheelHeader(child: Text('Value')),
                    decimal: WheelHeader(child: Text('Decimal')),
                    unit: WheelHeader(child: Text('Unit')),
                  ),
                  overlay: WheelOverlay.outlined(borderColor: primaryColor),
                ),
              ),
            ),
            result: ValueListenableBuilder<double>(
              valueListenable: _controller.valueListenable,
              builder: (context, val, _) {
                return Text(
                  'Selected Weight: ${val.toStringAsFixed(1)} ${_controller.currentUnit ?? ''}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                );
              },
            ),
            code: '''// Number Picker with Integer, Decimal, & Unit
WheelNumberChoice(
  value: 68.5,
  min: 30,
  max: 200,
  precision: 1,
  units: const ['kg', 'lbs'],
  itemExtent: 44,
  itemVisible: 5,
  spacing: 8,
  header: const WheelNumberHeader(
    integer: WheelHeader(child: Text('Value')),
    decimal: WheelHeader(child: Text('Decimal')),
    unit: WheelHeader(child: Text('Unit')),
  ),
  overlay: WheelOverlay.outlined(),
  onChanged: (double val, String? unit) {
    print('Picked: \$val \$unit');
  },
)''',
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 4: DATE RANGE
// -----------------------------------------------------------------------------
class _RangeTab extends StatefulWidget {
  const _RangeTab();

  @override
  State<_RangeTab> createState() => _RangeTabState();
}

class _RangeTabState extends State<_RangeTab> {
  late final WheelDateRangeController _controller;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _controller = WheelDateRangeController(
      value: DateTimeRange(start: now, end: now.add(const Duration(days: 7))),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: _ExampleCard(
            title: 'WheelDateRangeChoice (Start & End Date Booking)',
            description: 'Two synchronized date selectors enforcing start <= end range logic.',
            picker: Card(
              elevation: 0,
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                child: WheelDateRangeChoice.raw(
                  controller: _controller,
                  itemExtent: 44,
                  itemVisible: 5,
                  spacing: 4,
                  startHeader: const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('Check-In', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  endHeader: const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('Check-Out', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  overlay: WheelOverlay.outlined(borderColor: primaryColor),
                ),
              ),
            ),
            result: ValueListenableBuilder<DateTimeRange>(
              valueListenable: _controller.valueListenable,
              builder: (context, r, _) {
                return Text(
                  'Range: ${r.start.year}-${r.start.month}-${r.start.day}  →  ${r.end.year}-${r.end.month}-${r.end.day} (${r.duration.inDays} days)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                );
              },
            ),
            code: '''// Date Range Picker
WheelDateRangeChoice(
  value: DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(days: 7)),
  ),
  itemExtent: 44,
  itemVisible: 5,
  startHeader: const Text('Check-In'),
  endHeader: const Text('Check-Out'),
  overlay: WheelOverlay.outlined(),
  onChanged: (DateTimeRange range) {
    print('Trip: \${range.start} -> \${range.end}');
  },
)''',
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 5: CASCADE SELECTION
// -----------------------------------------------------------------------------
class _CascadeTab extends StatelessWidget {
  const _CascadeTab();

  static const sampleTree = [
    WheelCascadeItem<String>(
      value: 'USA',
      label: 'United States',
      children: [
        WheelCascadeItem(
          value: 'CA',
          label: 'California',
          children: [
            WheelCascadeItem(value: 'LA', label: 'Los Angeles'),
            WheelCascadeItem(value: 'SF', label: 'San Francisco'),
            WheelCascadeItem(value: 'SD', label: 'San Diego'),
          ],
        ),
        WheelCascadeItem(
          value: 'NY',
          label: 'New York',
          children: [
            WheelCascadeItem(value: 'NYC', label: 'New York City'),
            WheelCascadeItem(value: 'BUF', label: 'Buffalo'),
          ],
        ),
      ],
    ),
    WheelCascadeItem<String>(
      value: 'ID',
      label: 'Indonesia',
      children: [
        WheelCascadeItem(
          value: 'JKT',
          label: 'DKI Jakarta',
          children: [
            WheelCascadeItem(value: 'JS', label: 'Jakarta Selatan'),
            WheelCascadeItem(value: 'JP', label: 'Jakarta Pusat'),
            WheelCascadeItem(value: 'JB', label: 'Jakarta Barat'),
          ],
        ),
        WheelCascadeItem(
          value: 'JBR',
          label: 'Jawa Barat',
          children: [
            WheelCascadeItem(value: 'BDG', label: 'Bandung'),
            WheelCascadeItem(value: 'BKS', label: 'Bekasi'),
            WheelCascadeItem(value: 'BGR', label: 'Bogor'),
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _ExampleCard(
            title: 'WheelCascadeChoice (Country → State → City)',
            description: 'Tree-based cascading picker where each choice filters downstream options.',
            picker: Card(
              elevation: 0,
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: WheelCascadeChoice<String>(
                  items: sampleTree,
                  itemExtent: 44,
                  itemVisible: 5,
                  spacing: 8,
                  overlay: WheelOverlay.outlined(borderColor: primaryColor),
                ),
              ),
            ),
            code: '''// Hierarchical Cascading Picker
WheelCascadeChoice<String>(
  items: [
    WheelCascadeItem(
      value: 'ID',
      label: 'Indonesia',
      children: [
        WheelCascadeItem(
          value: 'JKT',
          label: 'DKI Jakarta',
          children: [
            WheelCascadeItem(value: 'JS', label: 'Jakarta Selatan'),
          ],
        ),
      ],
    ),
  ],
  itemExtent: 44,
  itemVisible: 5,
  spacing: 8,
  overlay: WheelOverlay.outlined(),
  onChanged: (List<String?> path) {
    print('Selected Path: \$path');
  },
)''',
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 6: MODAL DIALOGS & BOTTOM SHEETS
// -----------------------------------------------------------------------------
class _DialogsTab extends StatefulWidget {
  const _DialogsTab();

  @override
  State<_DialogsTab> createState() => _DialogsTabState();
}

class _DialogsTabState extends State<_DialogsTab> {
  String _result = 'None';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: _ExampleCard(
            title: 'Ready-To-Use Modal Bottom Sheets',
            description: 'Call instant Cupertino/Material modal sheets with Cancel & Done buttons without writing any boilerplate.',
            picker: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final picked = await showWheelDatePicker(context: context);
                    if (picked != null) {
                      setState(() => _result = 'Date: ${picked.year}-${picked.month}-${picked.day}');
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Pick Date Modal'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final picked = await showWheelTimePicker(context: context, use24hFormat: false);
                    if (picked != null) {
                      setState(() => _result = 'Time (12h): ${picked.format(context)}');
                    }
                  },
                  icon: const Icon(Icons.access_time),
                  label: const Text('Pick Time Modal (12h)'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final picked = await showWheelTimePicker(context: context, use24hFormat: true);
                    if (picked != null) {
                      setState(() => _result = 'Time (24h): ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
                    }
                  },
                  icon: const Icon(Icons.schedule),
                  label: const Text('Pick Time Modal (24h)'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final picked = await showWheelDateTimePicker(context: context, use24hFormat: false);
                    if (picked != null) {
                      setState(() => _result = 'Date & Time: $picked');
                    }
                  },
                  icon: const Icon(Icons.more_time),
                  label: const Text('Pick Date & Time Modal'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final picked = await showWheelDurationPicker(context: context);
                    if (picked != null) {
                      setState(() => _result = 'Duration: ${picked.inMinutes} mins');
                    }
                  },
                  icon: const Icon(Icons.timer),
                  label: const Text('Pick Duration Modal'),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Last Result: $_result',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            code: '''// 1. Pick Date Modal
final date = await showWheelDatePicker(
  context: context,
  initialDate: DateTime.now(),
);

// 2. Pick Time Modal (12-hour or 24-hour)
final time = await showWheelTimePicker(
  context: context,
  use24hFormat: true, // or false for 12-hour
);

// 3. Pick Date & Time Modal
final dt = await showWheelDateTimePicker(
  context: context,
  use24hFormat: false,
);

// 4. Pick Duration Modal
final duration = await showWheelDurationPicker(
  context: context,
);''',
          ),
        ),
      ),
    );
  }
}

class _ExampleCard extends StatefulWidget {
  const _ExampleCard({
    required this.title,
    this.description,
    this.controls,
    required this.picker,
    this.result,
    required this.code,
  });

  final String title;
  final String? description;
  final Widget? controls;
  final Widget picker;
  final Widget? result;
  final String code;

  @override
  State<_ExampleCard> createState() => _ExampleCardState();
}

class _ExampleCardState extends State<_ExampleCard> {
  bool _showCode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: () => setState(() => _showCode = !_showCode),
              icon: Icon(_showCode ? Icons.visibility_outlined : Icons.code, size: 16),
              label: Text(_showCode ? 'Hide Code' : 'View Code'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
        if (widget.controls != null) ...[
          const SizedBox(height: 12),
          widget.controls!,
        ],
        const SizedBox(height: 12),
        widget.picker,
        if (widget.result != null) ...[
          const SizedBox(height: 12),
          Center(child: widget.result!),
        ],
        if (_showCode) ...[
          const SizedBox(height: 12),
          _CodeBox(code: widget.code),
        ],
      ],
    );
  }
}

class _DartSyntaxHighlighter {
  static const _keywordColor = Color(0xFFC678DD);
  static const _typeColor = Color(0xFFE5C07B);
  static const _stringColor = Color(0xFF98C379);
  static const _commentColor = Color(0xFF7F848E);
  static const _numberColor = Color(0xFFD19A66);
  static const _paramColor = Color(0xFFE06C75);
  static const _defaultColor = Color(0xFFABB2BF);

  static final _tokenRegex = RegExp(
    r'(?<comment>//[^\n]*)'
    r'|(?<string>\x27[^\x27\n]*\x27|"[^"\n]*")'
    r'|(?<param>\b[a-zA-Z_][a-zA-Z0-9_]*(?=\s*:))'
    r'|(?<keyword>\b(?:final|const|await|async|var|void|return|class|extends|with|implements|import|as|new|true|false|null|if|else|for|in|while|do|switch|case|default|break|continue|static|super|this|is|required)\b)'
    r'|(?<number>\b\d+(?:\.\d+)?\b)'
    r'|(?<type>\b[A-Z][a-zA-Z0-9_]*\b)',
  );

  static TextSpan format(String code) {
    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in _tokenRegex.allMatches(code)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: code.substring(lastEnd, match.start),
          style: const TextStyle(color: _defaultColor),
        ));
      }

      final matchedText = match.group(0)!;
      if (match.namedGroup('comment') != null) {
        spans.add(TextSpan(
          text: matchedText,
          style: const TextStyle(color: _commentColor, fontStyle: FontStyle.italic),
        ));
      } else if (match.namedGroup('string') != null) {
        spans.add(TextSpan(
          text: matchedText,
          style: const TextStyle(color: _stringColor),
        ));
      } else if (match.namedGroup('param') != null) {
        spans.add(TextSpan(
          text: matchedText,
          style: const TextStyle(color: _paramColor),
        ));
      } else if (match.namedGroup('keyword') != null) {
        spans.add(TextSpan(
          text: matchedText,
          style: const TextStyle(color: _keywordColor, fontWeight: FontWeight.w600),
        ));
      } else if (match.namedGroup('number') != null) {
        spans.add(TextSpan(
          text: matchedText,
          style: const TextStyle(color: _numberColor),
        ));
      } else if (match.namedGroup('type') != null) {
        spans.add(TextSpan(
          text: matchedText,
          style: const TextStyle(color: _typeColor),
        ));
      } else {
        spans.add(TextSpan(
          text: matchedText,
          style: const TextStyle(color: _defaultColor),
        ));
      }

      lastEnd = match.end;
    }

    if (lastEnd < code.length) {
      spans.add(TextSpan(
        text: code.substring(lastEnd),
        style: const TextStyle(color: _defaultColor),
      ));
    }

    return TextSpan(
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 12.5,
        height: 1.45,
      ),
      children: spans,
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5F56),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFBD2E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF27C93F),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Dart Code',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: Colors.white70),
                  tooltip: 'Copy Code',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copied to clipboard!'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText.rich(
              _DartSyntaxHighlighter.format(code),
            ),
          ),
        ],
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
