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
  late final WheelTimeController _timeController;
  late final WheelDateTimeController _dateTimeController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController = WheelDateController(value: now);
    _timeController = WheelTimeController(
      value: TimeOfDay.fromDateTime(now),
      use24hFormat: false,
    );
    _dateTimeController = WheelDateTimeController(
      value: now,
      use24hFormat: false,
      minuteStep: 5,
    );
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
              const Text(
                'WheelDateChoice (Date Only)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Card(
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
              const SizedBox(height: 12),
              ValueListenableBuilder<DateTime>(
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
              const SizedBox(height: 36),
              const Divider(),
              const SizedBox(height: 36),

              // 2. TIME ONLY
              const Text(
                'WheelTimeChoice (Time Only)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  child: WheelTimeChoice.raw(
                    controller: _timeController,
                    itemExtent: 44,
                    itemVisible: 5,
                    spacing: 12,
                    header: const WheelTimeHeader(
                      hour: WheelHeader(child: Text('Hour')),
                      minute: WheelHeader(child: Text('Minute')),
                      period: WheelHeader(child: Text('Period')),
                    ),
                    overlay: WheelOverlay.outlined(borderColor: primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<TimeOfDay>(
                valueListenable: _timeController.valueListenable,
                builder: (context, t, _) {
                  return Text(
                    'Selected Time: ${t.format(context)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                  );
                },
              ),
              const SizedBox(height: 36),
              const Divider(),
              const SizedBox(height: 36),

              // 3. COMBINED DATE & TIME
              const Text(
                'WheelDateTimeChoice (Combined Date & Time)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  child: WheelDateTimeChoice.raw(
                    controller: _dateTimeController,
                    itemExtent: 44,
                    itemVisible: 5,
                    spacing: 6,
                    overlay: WheelOverlay.outlined(borderColor: primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<DateTime>(
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            children: [
              const Text(
                'WheelDurationChoice (Timer & Duration)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                    overlay: WheelOverlay.outlined(
                      borderColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<Duration>(
                valueListenable: _controller.valueListenable,
                builder: (context, dur, _) {
                  final h = dur.inHours.toString().padLeft(2, '0');
                  final m = (dur.inMinutes % 60).toString().padLeft(2, '0');
                  final s = (dur.inSeconds % 60).toString().padLeft(2, '0');
                  return Text(
                    'Duration: $h:$m:$s (${dur.inMinutes} total minutes)',
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            children: [
              const Text(
                'WheelNumberChoice (Integer + Decimal + Unit)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                    overlay: WheelOverlay.outlined(
                      borderColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<double>(
                valueListenable: _controller.valueListenable,
                builder: (context, val, _) {
                  return Text(
                    'Selected Weight: ${val.toStringAsFixed(1)} ${_controller.currentUnit ?? ''}',
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Column(
            children: [
              const Text(
                'WheelDateRangeChoice (Start & End Date Booking)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                    overlay: WheelOverlay.outlined(
                      borderColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<DateTimeRange>(
                valueListenable: _controller.valueListenable,
                builder: (context, r, _) {
                  return Text(
                    'Range: ${r.start.year}-${r.start.month}-${r.start.day}  →  ${r.end.year}-${r.end.month}-${r.end.day} (${r.duration.inDays} days)',
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              const Text(
                'WheelCascadeChoice (Country → State → City)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  child: WheelCascadeChoice<String>(
                    items: sampleTree,
                    itemExtent: 44,
                    itemVisible: 5,
                    spacing: 8,
                    overlay: WheelOverlay.outlined(
                      borderColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
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
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ready-To-Use Modal Bottom Sheets',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Call instant Cupertino/Material modal sheets with Cancel & Done buttons without writing any boilerplate.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
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
                    setState(() => _result = 'Time: ${picked.format(context)}');
                  }
                },
                icon: const Icon(Icons.access_time),
                label: const Text('Pick Time Modal'),
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
              const SizedBox(height: 24),
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
