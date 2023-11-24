import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:health/health.dart';
import 'package:joint_replacement_movement/provider.dart';
import 'package:provider/provider.dart';
import 'package:personnummer/personnummer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => HealthFetcher(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hur GÅR det?'),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16),
          children: [
            if (!context.read<HealthFetcher>().isAuthorized)
              Wrap(
                spacing: 10,
                children: [
                  const Text(
                    'Tack för att du vill vara med och hjälpa till. Det första steget är att ge oss tillgång till din stegdata från Apple Health.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Button(
                      onPressed: () async {
                        await context.read<HealthFetcher>().fetchData();
                      },
                      disabled: context.watch<HealthFetcher>().isLoading,
                      text: 'Ge tillgång',
                    ),
                  ),
                ],
              ),
            if (context.read<HealthFetcher>().isAuthorized)
              const Wrap(
                spacing: 10,
                children: [
                  Text(
                      'Du har gett tillgång! Datat du kan ladda upp syns nedanför')
                ],
              ),
            const Divider(thickness: 3),
            context.watch<HealthFetcher>().isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: displayData(context),
                  ),
            if (context.watch<HealthFetcher>().healthDataList.isNotEmpty)
              const UploadData(),
          ],
        ),
      ),
    );
  }

  List<Widget> displayData(BuildContext context) {
    // split healthDataTypes based on type
    Map<HealthDataType, List<HealthDataPoint>> healthDataMap = {};

    for (HealthDataPoint dataPoint
        in context.watch<HealthFetcher>().healthDataList) {
      if (!healthDataMap.containsKey(dataPoint.type)) {
        healthDataMap[dataPoint.type] = [];
      }
      healthDataMap[dataPoint.type]!.add(dataPoint);
    }

    List<Widget> widgets = [];

    for (HealthDataType type in healthDataMap.keys) {
      widgets.add(
        HealthDataDisplayer(
          healthDataList: healthDataMap[type]!,
          type: type,
        ),
      );
    }

    return widgets;
  }
}

class HealthDataDisplayer extends StatelessWidget {
  final List<HealthDataPoint> healthDataList;
  final HealthDataType type;

  const HealthDataDisplayer(
      {super.key, required this.healthDataList, required this.type});

  DateTime get firstDataPointDate => healthDataList.last.dateFrom;
  DateTime get lastDataPointDate => healthDataList.first.dateFrom;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            _type(type.name),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          displayDates(),
        ]),
      ),
    );
  }

  String _type(String type) {
    switch (type) {
      case 'STEPS':
        return 'Steg';
      case 'WALKING_SPEED':
        return 'Gånghastighet';
      case 'WALKING_STEP_LENGTH':
        return 'Steglängd';
      case 'WALKING_STEADINESS':
        return 'Stadighet';
      case 'WALKING_ASYMMETRY_PERCENTAGE':
        return 'Asymmetrisk gång';
      case 'WALKING_DOUBLE_SUPPORT_PERCENTAGE':
        return 'Dubbelt stöd';
      default:
        return type;
    }
  }

  Widget displayDates() {
    return Row(
      children: [
        Text(
            'Data mellan: ${firstDataPointDate.toIso8601String().substring(0, 10)} - ${lastDataPointDate.toIso8601String().substring(0, 10)}'),
      ],
    );
  }
}

class PersonalIdFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll('-', '');

    if (newText.length > 8) {
      newText = newText.substring(0, 8) + '-' + newText.substring(8);
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class UploadData extends HookWidget {
  const UploadData({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.watch<HealthFetcher>().uploadSuccess) {
      return const Center(
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, size: 96, color: Colors.green),
            Text(
              'Data uppladdat, tack så mycket för din medverkan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ],
        ),
      );
    }

    final textController = useTextEditingController(text: '');
    final textValue = useState('');

    useEffect(() {
      void listener() {
        textValue.value = textController.text;
      }

      textController.addListener(listener);
      return () => textController.removeListener(listener);
    }, [textController]);

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.number,
            controller: textController,
            inputFormatters: [PersonalIdFormatter()],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Personnr (YYYYMMDD-XXXX)',
            ),
          ),
          Center(
            child: Button(
              onPressed: () async {
                await context.read<HealthFetcher>().uploadData(textValue.value);
              },
              disabled: !Personnummer.valid(textValue.value) &&
                  !context.watch<HealthFetcher>().isLoading,
              text: "Ladda upp stegdata",
            ),
          )
        ],
      ),
    );
  }
}

class Button extends StatelessWidget {
  final Function onPressed;
  final bool disabled;
  final bool loading;
  final String text;

  const Button({
    super.key,
    required this.onPressed,
    required this.text,
    this.disabled = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: TextButton(
        onPressed: () {
          if (!disabled) {
            onPressed();
          }
        },
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.blue),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Text(
                text,
                style: const TextStyle(color: Colors.white),
              ),
      ),
    );
  }
}
