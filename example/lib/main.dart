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
    _tabController = TabController(length: 7, vsync: this);
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
            Tab(icon: Icon(Icons.tune), text: 'Customization'),
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
          _CustomizationTab(),
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
  late WheelDurationController _controller;

  bool _showDays = false;
  bool _showHours = true;
  bool _showMinutes = true;
  bool _showSeconds = true;

  @override
  void initState() {
    super.initState();
    _recreateController(const Duration(hours: 1, minutes: 30, seconds: 0));
  }

  void _recreateController([Duration? current]) {
    final val = current ?? _controller.value;
    _controller = WheelDurationController(
      value: val,
      showDays: _showDays,
      showHours: _showHours,
      showMinutes: _showMinutes,
      showSeconds: _showSeconds,
    );
  }

  void _toggleMetric({bool? days, bool? hours, bool? minutes, bool? seconds}) {
    final nextDays = days ?? _showDays;
    final nextHours = hours ?? _showHours;
    final nextMinutes = minutes ?? _showMinutes;
    final nextSeconds = seconds ?? _showSeconds;

    // Ensure at least one metric remains active
    if (!nextDays && !nextHours && !nextMinutes && !nextSeconds) return;

    setState(() {
      _showDays = nextDays;
      _showHours = nextHours;
      _showMinutes = nextMinutes;
      _showSeconds = nextSeconds;
      final current = _controller.value;
      _controller.dispose();
      _recreateController(current);
    });
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
            description: 'Customizable days, hours, minutes, and seconds with on/off toggles.',
            controls: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Metrics:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    FilterChip(
                      label: const Text('Days'),
                      selected: _showDays,
                      onSelected: (val) => _toggleMetric(days: val),
                    ),
                    FilterChip(
                      label: const Text('Hours'),
                      selected: _showHours,
                      onSelected: (val) => _toggleMetric(hours: val),
                    ),
                    FilterChip(
                      label: const Text('Minutes'),
                      selected: _showMinutes,
                      onSelected: (val) => _toggleMetric(minutes: val),
                    ),
                    FilterChip(
                      label: const Text('Seconds'),
                      selected: _showSeconds,
                      onSelected: (val) => _toggleMetric(seconds: val),
                    ),
                  ],
                ),
              ],
            ),
            picker: Card(
              elevation: 0,
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: WheelDurationChoice.raw(
                  key: ValueKey('$_showDays-$_showHours-$_showMinutes-$_showSeconds'),
                  controller: _controller,
                  itemExtent: 44,
                  itemVisible: 5,
                  spacing: 12,
                  itemLabel: WheelDurationLabel.suffix(),
                  header: WheelDurationHeader(
                    days: _showDays ? const WheelHeader(child: Text('Days')) : null,
                    hours: _showHours ? const WheelHeader(child: Text('Hours')) : null,
                    minutes: _showMinutes ? const WheelHeader(child: Text('Mins')) : null,
                    seconds: _showSeconds ? const WheelHeader(child: Text('Secs')) : null,
                  ),
                  overlay: WheelOverlay.outlined(borderColor: primaryColor),
                ),
              ),
            ),
            result: ValueListenableBuilder<Duration>(
              valueListenable: _controller.valueListenable,
              builder: (context, dur, _) {
                final parts = <String>[];
                if (_showDays) parts.add('${dur.inDays}d');
                if (_showHours) parts.add('${dur.inHours % 24}h');
                if (_showMinutes) parts.add('${dur.inMinutes % 60}m');
                if (_showSeconds) parts.add('${dur.inSeconds % 60}s');
                return Text(
                  'Duration: ${parts.isEmpty ? '0s' : parts.join(' ')} (${dur.inMinutes} total mins)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                );
              },
            ),
            code: '''// Modular Duration Wheel (Customized Units)
WheelDurationChoice(
  value: const Duration(${_showDays ? 'days: 1, ' : ''}hours: 1, minutes: 30),${_showDays ? '\n  showDays: true,' : ''}${!_showHours ? '\n  showHours: false,' : ''}${!_showMinutes ? '\n  showMinutes: false,' : ''}${!_showSeconds ? '\n  showSeconds: false,' : ''}
  itemExtent: 44,
  itemVisible: 5,
  spacing: 12,
  itemLabel: WheelDurationLabel.suffix(),
  header: const WheelDurationHeader(${_showDays ? "\n    days: WheelHeader(child: Text('Days'))," : ''}${_showHours ? "\n    hours: WheelHeader(child: Text('Hours'))," : ''}${_showMinutes ? "\n    minutes: WheelHeader(child: Text('Mins'))," : ''}${_showSeconds ? "\n    seconds: WheelHeader(child: Text('Secs'))," : ''}
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
class _CascadeTab extends StatefulWidget {
  const _CascadeTab();

  @override
  State<_CascadeTab> createState() => _CascadeTabState();
}

class _CascadeTabState extends State<_CascadeTab> {
  late final WheelCascadeController<String> _syncCtrl;
  late final WheelCascadeController<String> _asyncCtrl;

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
    WheelCascadeItem<String>(
      value: 'JP',
      label: 'Japan',
      children: [
        WheelCascadeItem(
          value: 'KNT',
          label: 'Kanto',
          children: [
            WheelCascadeItem(value: 'TKO', label: 'Tokyo'),
            WheelCascadeItem(value: 'YKH', label: 'Yokohama'),
          ],
        ),
        WheelCascadeItem(
          value: 'KSK',
          label: 'Kansai',
          children: [
            WheelCascadeItem(value: 'OSK', label: 'Osaka'),
            WheelCascadeItem(value: 'KYT', label: 'Kyoto'),
          ],
        ),
      ],
    ),
  ];

  static Future<List<WheelCascadeItem<String>>> _mockAsyncLoader(
    int level,
    List<String> selected,
  ) async {
    // Simulates remote network latency (350ms)
    await Future.delayed(const Duration(milliseconds: 350));

    if (level == 0) {
      return const [
        WheelCascadeItem(value: 'asia', label: 'Asia'),
        WheelCascadeItem(value: 'europe', label: 'Europe'),
        WheelCascadeItem(value: 'americas', label: 'Americas'),
      ];
    } else if (level == 1) {
      final continent = selected.isNotEmpty ? selected[0] : 'asia';
      switch (continent) {
        case 'asia':
          return const [
            WheelCascadeItem(value: 'jp', label: 'Japan'),
            WheelCascadeItem(value: 'id', label: 'Indonesia'),
            WheelCascadeItem(value: 'kr', label: 'South Korea'),
          ];
        case 'europe':
          return const [
            WheelCascadeItem(value: 'de', label: 'Germany'),
            WheelCascadeItem(value: 'fr', label: 'France'),
            WheelCascadeItem(value: 'uk', label: 'United Kingdom'),
          ];
        case 'americas':
        default:
          return const [
            WheelCascadeItem(value: 'us', label: 'United States'),
            WheelCascadeItem(value: 'ca', label: 'Canada'),
            WheelCascadeItem(value: 'br', label: 'Brazil'),
          ];
      }
    } else {
      final country = selected.length > 1 ? selected[1] : '';
      switch (country) {
        case 'jp':
          return const [
            WheelCascadeItem(value: 'tko', label: 'Tokyo'),
            WheelCascadeItem(value: 'osk', label: 'Osaka'),
          ];
        case 'id':
          return const [
            WheelCascadeItem(value: 'jkt', label: 'Jakarta'),
            WheelCascadeItem(value: 'sub', label: 'Surabaya'),
          ];
        case 'kr':
          return const [
            WheelCascadeItem(value: 'seo', label: 'Seoul'),
            WheelCascadeItem(value: 'bus', label: 'Busan'),
          ];
        case 'de':
          return const [
            WheelCascadeItem(value: 'ber', label: 'Berlin'),
            WheelCascadeItem(value: 'mun', label: 'Munich'),
          ];
        case 'fr':
          return const [
            WheelCascadeItem(value: 'par', label: 'Paris'),
            WheelCascadeItem(value: 'lyo', label: 'Lyon'),
          ];
        case 'uk':
          return const [
            WheelCascadeItem(value: 'lon', label: 'London'),
            WheelCascadeItem(value: 'man', label: 'Manchester'),
          ];
        case 'us':
          return const [
            WheelCascadeItem(value: 'was', label: 'Washington D.C.'),
            WheelCascadeItem(value: 'nyc', label: 'New York'),
          ];
        case 'ca':
          return const [
            WheelCascadeItem(value: 'ott', label: 'Ottawa'),
            WheelCascadeItem(value: 'tor', label: 'Toronto'),
          ];
        case 'br':
        default:
          return const [
            WheelCascadeItem(value: 'bsb', label: 'Brasília'),
            WheelCascadeItem(value: 'sao', label: 'São Paulo'),
          ];
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _syncCtrl = WheelCascadeController<String>(items: sampleTree);
    _asyncCtrl = WheelCascadeController<String>(
      depth: 3,
      optionsLoader: _mockAsyncLoader,
    );
  }

  @override
  void dispose() {
    _syncCtrl.dispose();
    _asyncCtrl.dispose();
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
              // 1. SYNCHRONOUS TREE CASCADE
              _ExampleCard(
                title: 'WheelCascadeChoice (Sync Tree)',
                description:
                    'Hierarchical cascading tree where each selection instantly cascades downstream options.',
                picker: Card(
                  elevation: 0,
                  color: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    child: WheelCascadeChoice<String>.raw(
                      controller: _syncCtrl,
                      itemExtent: 44,
                      itemVisible: 5,
                      spacing: 8,
                      header: const [
                        WheelHeader(child: Text('Country')),
                        WheelHeader(child: Text('State / Prov')),
                        WheelHeader(child: Text('City')),
                      ],
                      overlay: WheelOverlay.outlined(borderColor: primaryColor),
                    ),
                  ),
                ),
                result: ValueListenableBuilder<List<String>>(
                  valueListenable: _syncCtrl.valueListenable,
                  builder: (context, values, _) {
                    final labels = <String>[];
                    for (var i = 0; i < values.length; i++) {
                      labels.add(_syncCtrl.labelFor(i, values[i]));
                    }
                    return Text(
                      'Selected: ${labels.join('  ›  ')} (${values.join(' / ')})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                    );
                  },
                ),
                code: '''// Synchronous Cascading Tree
WheelCascadeChoice<String>(
  items: const [
    WheelCascadeItem(
      value: 'ID',
      label: 'Indonesia',
      children: [
        WheelCascadeItem(
          value: 'JKT',
          label: 'DKI Jakarta',
          children: [
            WheelCascadeItem(value: 'JS', label: 'Jakarta Selatan'),
            WheelCascadeItem(value: 'JP', label: 'Jakarta Pusat'),
          ],
        ),
      ],
    ),
  ],
  itemExtent: 44,
  itemVisible: 5,
  spacing: 8,
  header: const [
    WheelHeader(child: Text('Country')),
    WheelHeader(child: Text('State / Prov')),
    WheelHeader(child: Text('City')),
  ],
  overlay: WheelOverlay.outlined(),
  onChanged: (List<String> path) {
    print('Selected Path: \$path');
  },
)''',
              ),
              const SizedBox(height: 36),
              const Divider(),
              const SizedBox(height: 36),

              // 2. ASYNCHRONOUS API CASCADE
              _ExampleCard(
                title: 'WheelCascadeChoice.builder (Async Loader)',
                description:
                    'Dynamic async data fetching per level with built-in loading spinners and race condition handling.',
                picker: Card(
                  elevation: 0,
                  color: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    child: WheelCascadeChoice<String>.raw(
                      controller: _asyncCtrl,
                      itemExtent: 44,
                      itemVisible: 5,
                      spacing: 8,
                      header: const [
                        WheelHeader(child: Text('Continent')),
                        WheelHeader(child: Text('Country')),
                        WheelHeader(child: Text('City')),
                      ],
                      overlay: WheelOverlay.outlined(borderColor: primaryColor),
                    ),
                  ),
                ),
                result: ValueListenableBuilder<List<String>>(
                  valueListenable: _asyncCtrl.valueListenable,
                  builder: (context, values, _) {
                    final labels = <String>[];
                    for (var i = 0; i < values.length; i++) {
                      labels.add(_asyncCtrl.labelFor(i, values[i]));
                    }
                    return Text(
                      'Async Selected: ${labels.join('  ›  ')} (${values.join(' / ')})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                    );
                  },
                ),
                code: '''// Asynchronous Dynamic Cascading Picker
WheelCascadeChoice<String>.builder(
  depth: 3,
  optionsLoader: (int level, List<String> selected) async {
    // Fetch options from API based on upstream selections
    if (level == 0) return await api.fetchContinents();
    if (level == 1) return await api.fetchCountries(continent: selected[0]);
    return await api.fetchCities(country: selected[1]);
  },
  itemExtent: 44,
  itemVisible: 5,
  spacing: 8,
  header: const [
    WheelHeader(child: Text('Continent')),
    WheelHeader(child: Text('Country')),
    WheelHeader(child: Text('City')),
  ],
  overlay: WheelOverlay.outlined(),
  onChanged: (List<String> path) {
    print('Async Path: \$path');
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
// TAB 6: CUSTOMIZATION & FLEXIBILITY
// -----------------------------------------------------------------------------
class _CustomizationTab extends StatefulWidget {
  const _CustomizationTab();

  @override
  State<_CustomizationTab> createState() => _CustomizationTabState();
}

class _PaymentItem {
  const _PaymentItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    this.badge,
    this.badgeColor,
  });

  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final String? badge;
  final Color? badgeColor;
}

class _ColorItem {
  const _ColorItem({
    required this.name,
    required this.hex,
    required this.color,
  });

  final String name;
  final String hex;
  final Color color;
}

class _CustomizationTabState extends State<_CustomizationTab> {
  // 1. Playground State
  bool _isCylinder = true;
  double _magnification = 1.15;
  double _squeeze = 1.1;
  double _opacity = 0.5;
  double _itemExtent = 44;
  final int _itemVisible = 5;
  final bool _loop = false;
  int _overlayStyleIndex = 0; // 0: Outlined, 1: Filled, 2: Dual Divider, 3: Gradient Glow

  late final WheelController<String> _playgroundCtrl;
  String _selectedMonth = 'July';

  // 2. Rich Item State
  late final WheelController<String> _paymentCtrl;
  String _selectedPayment = 'visa';

  // 3. Color Swatch State
  late final WheelController<int> _colorCtrl;
  int _selectedColorIndex = 0;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _paymentMethods = [
    _PaymentItem(
      id: 'visa',
      name: 'Visa Card',
      subtitle: '•••• 4242 (Personal)',
      icon: Icons.credit_card,
      badge: 'Default',
      badgeColor: Color(0xFF10B981),
    ),
    _PaymentItem(
      id: 'mc',
      name: 'Mastercard',
      subtitle: '•••• 8821 (Corporate)',
      icon: Icons.credit_card,
      badge: null,
      badgeColor: null,
    ),
    _PaymentItem(
      id: 'paypal',
      name: 'PayPal Account',
      subtitle: 'user@example.com',
      icon: Icons.account_balance_wallet,
      badge: 'Verified',
      badgeColor: Color(0xFF3B82F6),
    ),
    _PaymentItem(
      id: 'apple',
      name: 'Apple Pay',
      subtitle: 'Touch ID / Face ID',
      icon: Icons.phone_iphone,
      badge: 'Fast',
      badgeColor: Color(0xFF8B5CF6),
    ),
    _PaymentItem(
      id: 'crypto',
      name: 'Crypto Vault',
      subtitle: 'USDC / ETH / BTC',
      icon: Icons.currency_bitcoin,
      badge: null,
      badgeColor: null,
    ),
  ];

  static const _colorSwatches = [
    _ColorItem(name: 'Electric Indigo', hex: '#6366F1', color: Color(0xFF6366F1)),
    _ColorItem(name: 'Emerald Green', hex: '#10B981', color: Color(0xFF10B981)),
    _ColorItem(name: 'Amber Gold', hex: '#F59E0B', color: Color(0xFFF59E0B)),
    _ColorItem(name: 'Crimson Red', hex: '#EF4444', color: Color(0xFFEF4444)),
    _ColorItem(name: 'Cyber Violet', hex: '#8B5CF6', color: Color(0xFF8B5CF6)),
    _ColorItem(name: 'Neon Cyan', hex: '#06B6D4', color: Color(0xFF06B6D4)),
    _ColorItem(name: 'Rose Pink', hex: '#EC4899', color: Color(0xFFEC4899)),
  ];

  @override
  void initState() {
    super.initState();
    _playgroundCtrl = WheelController<String>(
      options: _months,
      value: _selectedMonth,
      loop: _loop,
      onChanged: (v) => setState(() => _selectedMonth = v),
    );
    _paymentCtrl = WheelController<String>(
      options: _paymentMethods.map((e) => e.id).toList(),
      value: _selectedPayment,
      onChanged: (v) => setState(() => _selectedPayment = v),
    );
    _colorCtrl = WheelController<int>(
      options: List.generate(_colorSwatches.length, (i) => i),
      value: _selectedColorIndex,
      onChanged: (v) => setState(() => _selectedColorIndex = v),
    );
  }

  @override
  void dispose() {
    _playgroundCtrl.dispose();
    _paymentCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  WidgetBuilder? _buildPlaygroundOverlay(Color primaryColor) {
    switch (_overlayStyleIndex) {
      case 0:
        return WheelOverlay.delegate(
          border: Border.all(color: primaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        );
      case 1:
        return WheelOverlay.filled(
          color: primaryColor.withValues(alpha: 0.12),
          cornerRadius: 12,
        );
      case 2:
        return WheelOverlay.outlined(
          borderColor: primaryColor.withValues(alpha: 0.5),
        );
      case 3:
        return (context) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.2),
                    Colors.transparent,
                    primaryColor.withValues(alpha: 0.2),
                  ],
                ),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            );
      default:
        return null;
    }
  }

  String get _overlayName {
    switch (_overlayStyleIndex) {
      case 0:
        return 'WheelOverlay.outlined(...)';
      case 1:
        return 'WheelOverlay.filled(...)';
      case 2:
        return 'Cupertino Dual Dividers';
      case 3:
        return 'Gradient Glow Border';
      default:
        return 'None';
    }
  }

  Widget _buildPaymentRow(
    BuildContext context,
    WheelItem<String> item,
    Color primaryColor,
  ) {
    final pay = _paymentMethods.firstWhere((e) => e.id == item.data);
    final isSelected = item.selected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              pay.icon,
              size: 20,
              color: isSelected ? primaryColor : Colors.grey,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pay.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                    color: isSelected ? null : Colors.grey,
                  ),
                ),
                Text(
                  pay.subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (pay.badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (pay.badgeColor ?? primaryColor)
                    .withValues(alpha: isSelected ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: (pay.badgeColor ?? primaryColor)
                      .withValues(alpha: isSelected ? 0.6 : 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                pay.badge!,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: pay.badgeColor ?? primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColorRow(BuildContext context, WheelItem<int> item) {
    final swatch = _colorSwatches[item.data];
    final isSelected = item.selected;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: swatch.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white54,
                width: isSelected ? 2.5 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: swatch.color.withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              swatch.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            swatch.hex,
            style: const TextStyle(
              fontFamily: 'Consolas',
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    final currentEffect = _isCylinder
        ? WheelEffect(
            useMagnifier: true,
            magnification: _magnification,
            squeeze: _squeeze,
            perspective: 0.003,
            overAndUnderCenterOpacity: _opacity,
          )
        : WheelEffect.flat(
            useMagnifier: true,
            magnification: _magnification,
            squeeze: _squeeze,
            overAndUnderCenterOpacity: _opacity,
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              // 1. LIVE INTERACTIVE PLAYGROUND
              _ExampleCard(
                title: 'Visual Effect & Overlay Studio (Playground)',
                description:
                    'Adjust 3D cylinder depth, squeeze, edge opacity, and overlay styles dynamically.',
                controls: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 3D Curvature
                    const Text('3D Geometry:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Cylinder 3D'), icon: Icon(Icons.view_in_ar)),
                        ButtonSegment(value: false, label: Text('Flat 2D'), icon: Icon(Icons.crop_portrait)),
                      ],
                      selected: {_isCylinder},
                      onSelectionChanged: (v) => setState(() => _isCylinder = v.first),
                    ),
                    const SizedBox(height: 14),

                    // Overlay Style
                    const Text('Selection Overlay:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ChoiceChip(
                          label: const Text('Outlined'),
                          selected: _overlayStyleIndex == 0,
                          onSelected: (_) => setState(() => _overlayStyleIndex = 0),
                        ),
                        ChoiceChip(
                          label: const Text('Filled Tint'),
                          selected: _overlayStyleIndex == 1,
                          onSelected: (_) => setState(() => _overlayStyleIndex = 1),
                        ),
                        ChoiceChip(
                          label: const Text('Dual Dividers'),
                          selected: _overlayStyleIndex == 2,
                          onSelected: (_) => setState(() => _overlayStyleIndex = 2),
                        ),
                        ChoiceChip(
                          label: const Text('Neon Glow'),
                          selected: _overlayStyleIndex == 3,
                          onSelected: (_) => setState(() => _overlayStyleIndex = 3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Sliders
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Magnification: ${_magnification.toStringAsFixed(2)}x',
                                  style: const TextStyle(fontSize: 12)),
                              Slider(
                                value: _magnification,
                                min: 1.0,
                                max: 1.4,
                                divisions: 8,
                                onChanged: (v) => setState(() => _magnification = v),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Squeeze: ${_squeeze.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 12)),
                              Slider(
                                value: _squeeze,
                                min: 0.8,
                                max: 1.4,
                                divisions: 6,
                                onChanged: (v) => setState(() => _squeeze = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fade Opacity: ${_opacity.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 12)),
                              Slider(
                                value: _opacity,
                                min: 0.2,
                                max: 1.0,
                                divisions: 8,
                                onChanged: (v) => setState(() => _opacity = v),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Row Height: ${_itemExtent.toInt()}px',
                                  style: const TextStyle(fontSize: 12)),
                              Slider(
                                value: _itemExtent,
                                min: 36,
                                max: 60,
                                divisions: 6,
                                onChanged: (v) => setState(() => _itemExtent = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                picker: Card(
                  elevation: 0,
                  color: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: SizedBox(
                      height: _itemExtent * _itemVisible,
                      child: WheelChoice<String>.raw(
                        key: ValueKey('$_isCylinder-$_overlayStyleIndex-$_itemExtent-$_itemVisible-$_loop'),
                        controller: _playgroundCtrl,
                        itemExtent: _itemExtent,
                        itemVisible: _itemVisible,
                        effect: currentEffect,
                        overlay: _buildPlaygroundOverlay(primaryColor),
                      ),
                    ),
                  ),
                ),
                result: Text(
                  'Selected: $_selectedMonth (Overlay: $_overlayName)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                ),
                code: '''// Custom 3D Effect & Overlay Configuration
WheelChoice<String>(
  options: const ['January', 'February', 'March', ...],
  value: '$_selectedMonth',
  itemExtent: ${_itemExtent.toInt()},
  itemVisible: $_itemVisible,
  effect: const WheelEffect${_isCylinder ? '' : '.flat'}(
    useMagnifier: true,
    magnification: ${_magnification.toStringAsFixed(2)},
    squeeze: ${_squeeze.toStringAsFixed(2)},
    overAndUnderCenterOpacity: ${_opacity.toStringAsFixed(2)},
  ),
  overlay: ${_overlayStyleIndex == 0 ? "WheelOverlay.outlined(borderColor: primaryColor)" : _overlayStyleIndex == 1 ? "WheelOverlay.filled(color: primaryColor.withValues(alpha: 0.12))" : "// Custom widget builder\n  (context) => Container(...)"},
  onChanged: (String month) {
    print('Selected: \$month');
  },
)''',
              ),
              const SizedBox(height: 36),
              const Divider(),
              const SizedBox(height: 36),

              // 2. RICH ITEM BUILDER (PAYMENT METHODS)
              _ExampleCard(
                title: 'Rich Item Builder (Icons, Subtitles & Badges)',
                description:
                    'Replace plain strings with full Flutter widget trees using `itemBuilder` and `WheelItem`.',
                picker: Card(
                  elevation: 0,
                  color: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    child: SizedBox(
                      height: 52.0 * 5,
                      child: WheelChoice<String>.raw(
                        controller: _paymentCtrl,
                        itemExtent: 52,
                        itemVisible: 5,
                        effect: const WheelEffect(
                          useMagnifier: true,
                          magnification: 1.08,
                          squeeze: 1.1,
                          perspective: 0.003,
                        ),
                        overlay: WheelOverlay.delegate(
                          border: Border.all(color: primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        itemBuilder: (context, item) =>
                            _buildPaymentRow(context, item, primaryColor),
                      ),
                    ),
                  ),
                ),
                result: Text(
                  'Payment Selected: ${_paymentMethods.firstWhere((e) => e.id == _selectedPayment).name}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                ),
                code: '''// Custom Rich Row Builder (Payment Method Wheel)
WheelChoice<String>(
  options: const ['visa', 'mc', 'paypal', 'apple', 'crypto'],
  value: '$_selectedPayment',
  itemExtent: 52,
  itemVisible: 5,
  overlay: WheelOverlay.outlined(borderRadius: BorderRadius.circular(14)),
  itemBuilder: (BuildContext context, WheelItem<String> item) {
    final isSelected = item.selected;
    final payment = getPaymentById(item.data);

    return Row(
      children: [
        Icon(payment.icon, color: isSelected ? primaryColor : Colors.grey),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(payment.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            Text(payment.subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        if (payment.badge != null)
          Badge(label: Text(payment.badge!)),
      ],
    );
  },
)''',
              ),
              const SizedBox(height: 36),
              const Divider(),
              const SizedBox(height: 36),

              // 3. COLOR PALETTE SWATCH CHOOSER
              _ExampleCard(
                title: 'Color Palette & Hex Swatch Wheel',
                description:
                    'Dynamic color indicators with circular glowing shadows on active items.',
                picker: Card(
                  elevation: 0,
                  color: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    child: SizedBox(
                      height: 48.0 * 5,
                      child: WheelChoice<int>.raw(
                        controller: _colorCtrl,
                        itemExtent: 48,
                        itemVisible: 5,
                        effect: const WheelEffect(
                          useMagnifier: true,
                          magnification: 1.1,
                          squeeze: 1.15,
                        ),
                        overlay: WheelOverlay.filled(
                          color: _colorSwatches[_selectedColorIndex].color.withValues(alpha: 0.15),
                          cornerRadius: 12,
                        ),
                        itemBuilder: (context, item) => _buildColorRow(context, item),
                      ),
                    ),
                  ),
                ),
                result: Text(
                  'Color: ${_colorSwatches[_selectedColorIndex].name} (${_colorSwatches[_selectedColorIndex].hex})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _colorSwatches[_selectedColorIndex].color,
                      ),
                ),
                code: '''// Custom Color Swatch Selector
WheelChoice<int>(
  options: const [0, 1, 2, 3, 4, 5, 6],
  itemExtent: 48,
  itemVisible: 5,
  itemBuilder: (context, item) {
    final swatch = colorSwatches[item.data];
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: swatch.color,
            shape: BoxShape.circle,
            boxShadow: item.selected ? [BoxShadow(color: swatch.color.withValues(alpha: 0.6), blurRadius: 8)] : null,
          ),
        ),
        const SizedBox(width: 16),
        Text(swatch.name),
        const Spacer(),
        Text(swatch.hex, style: const TextStyle(fontFamily: 'Consolas')),
      ],
    );
  },
)''',
              ),
              const SizedBox(height: 36),
              const Divider(),
              const SizedBox(height: 36),

              // 4. WHEEL CHOICE THEME (GLOBAL INHERITANCE)
              _ExampleCard(
                title: 'WheelChoiceTheme (Ambient Styling Inheritance)',
                description:
                    'Wrap multiple pickers in a theme provider to propagate height, visible count, and overlay seamlessly.',
                picker: Card(
                  elevation: 0,
                  color: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: WheelChoiceTheme(
                      data: WheelChoiceThemeData(
                        itemExtent: 46,
                        itemVisible: 5,
                        effect: const WheelEffect(
                          useMagnifier: true,
                          magnification: 1.12,
                          squeeze: 1.15,
                          perspective: 0.003,
                        ),
                        overlay: WheelOverlay.delegate(
                          border: Border.all(
                            color: Colors.tealAccent.shade700,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Inheriting Teal Outlined Theme & 46px Height:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          WheelTimeChoice(
                            value: const TimeOfDay(hour: 14, minute: 30),
                            use24hFormat: true,
                            spacing: 12,
                            header: const WheelTimeHeader(
                              hour: WheelHeader(child: Text('HH')),
                              minute: WheelHeader(child: Text('MM')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                result: const Text(
                  'Theme applied via WheelChoiceThemeData',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                code: '''// Propagating Styles via WheelChoiceTheme
WheelChoiceTheme(
  data: WheelChoiceThemeData(
    itemExtent: 46,
    itemVisible: 5,
    effect: const WheelEffect(
      useMagnifier: true,
      magnification: 1.12,
      squeeze: 1.15,
    ),
    overlay: WheelOverlay.outlined(
      borderColor: Colors.tealAccent.shade700,
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  child: WheelTimeChoice(
    value: TimeOfDay.now(),
    use24hFormat: true,
  ),
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
// TAB 7: MODAL DIALOGS & BOTTOM SHEETS
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
        fontFamily: 'Consolas',
        fontFamilyFallback: [
          'Menlo',
          'Monaco',
          'Courier New',
          'monospace',
        ],
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
