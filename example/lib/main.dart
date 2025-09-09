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
  DateTime _date = DateTime.now();
  WheelDateOrder? _order; // null means locale-aware

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('id'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'wheel_choice_ext example',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Wheel Date Choice Example')),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Locale switcher
                    const Text('Locale:'),
                    const SizedBox(width: 8),
                    DropdownButton<Locale>(
                      value: _locale,
                      items: const [
                        DropdownMenuItem(value: Locale('en'), child: Text('English (en)')),
                        DropdownMenuItem(value: Locale('id'), child: Text('Indonesia (id)')),
                      ],
                      onChanged: (loc) => setState(() => _locale = loc ?? _locale),
                    ),
                    const Spacer(),
                    const Text('Order:'),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _order == null
                          ? 'locale'
                          : (_order == WheelDateOrder.mdy
                              ? 'mdy'
                              : _order == WheelDateOrder.ymd
                                  ? 'ymd'
                                  : _order == WheelDateOrder.ydm
                                      ? 'ydm'
                                      : 'dmy'),
                      items: const [
                        DropdownMenuItem(value: 'locale', child: Text('Locale-based')),
                        DropdownMenuItem(value: 'dmy', child: Text('DMY')),
                        DropdownMenuItem(value: 'mdy', child: Text('MDY')),
                        DropdownMenuItem(value: 'ymd', child: Text('YMD')),
                        DropdownMenuItem(value: 'ydm', child: Text('YDM')),
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
                            case 'ydm':
                              _order = WheelDateOrder.ydm;
                              break;
                            default:
                              _order = null;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // The wheel date picker itself
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          WheelDateChoice(
                            value: _date,
                            onChanged: (d) => setState(() => _date = d),
                            itemExtent: 44,
                            itemVisible: 5,
                            spacing: 12,
                            flex: const WheelDateFlex(day: 3, month: 4, year: 4),
                            minYear: 1900,
                            maxYear: 2100,
                            order: _order,
                            // Labels default to locale-aware via WheelDateLabel.of(context)
                          ),
                          const SizedBox(height: 24),
                          // Display the selected date
                          Text(
                            'Selected: '
                            '${_date.year.toString().padLeft(4, '0')}-'
                            '${_date.month.toString().padLeft(2, '0')}-'
                            '${_date.day.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
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
