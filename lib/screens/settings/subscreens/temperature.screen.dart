import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/input.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/models/relay.model.dart';
import 'package:iot/util/functions.util.dart';
import 'package:provider/provider.dart';

class TemperatureAlertScreen extends StatefulWidget {
  final Device device;
  const TemperatureAlertScreen({Key? key, required this.device}) : super(key: key);

  @override
  State<TemperatureAlertScreen> createState() => _TemperatureAlertScreenState();
}

class _TemperatureAlertScreenState extends State<TemperatureAlertScreen> {
  bool isLoading = false;
  bool shouldAlert = false;

  late final TextEditingController temperature;
  late final DeviceController controller;
  late final UserController userController;
  late final Relay relay;

  String formError = '';
  String temperatureError = '';

  @override
  void initState() {
    super.initState();

    final int? value = widget.device.temperatureAlert;

    temperature = TextEditingController(text: value != null ? value.toString() : '0');
    controller = Provider.of<DeviceController>(context, listen: false);
    userController = Provider.of<UserController>(context, listen: false);
  }

  bool validateTemperature() {
    if (temperature.text == "") {
      setState(() {
        temperatureError = "This field cannot be empty!";
      });

      return false;
    } else if (int.tryParse(temperature.text) == null) {
      setState(() {
        temperatureError = "Temperature must be a valid integer";
      });

      return false;
    }

    if (temperatureError != '') {
      setState(() {
        temperatureError = '';
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Temperature alert"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SwitchListTile(
                        title: const Text(
                          "Alert",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          shouldAlert ? "Set to alert" : "Don't alert",
                          style: const TextStyle(fontSize: 11),
                        ),
                        value: shouldAlert,
                        onChanged: (value) {
                          setState(() {
                            shouldAlert = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomInput(
                        label: "Temperature Alert",
                        icon: Icons.sensors,
                        disabled: !shouldAlert,
                        error: temperatureError,
                        controller: temperature,
                      ),
                      if (formError != '')
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            formError,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                CustomButton(
                  text: "Update temperature alert",
                  onPressed: () async {
                    final bool isTemperatureValid = validateTemperature();

                    if (!isTemperatureValid) {
                      return;
                    }

                    setState(() {
                      isLoading = true;
                    });

                    final int? previousValue = widget.device.temperatureAlert;

                    try {
                      controller.devices[widget.device.id]!.temperatureAlert = shouldAlert ? int.parse(temperature.text) : null;
                      await controller.updateDevice(controller.devices[widget.device.id]!);

                      showMessage(context, "Controller updated successfully!");
                      Navigator.pop(context);
                    } catch (e) {
                      setState(() {
                        formError = e.toString();
                        isLoading = false;
                      });

                      controller.devices[widget.device.id]!.temperatureAlert = previousValue;
                      showMessage(context, "Failed to update the controller");
                    }
                  },
                ),
              ],
            ),
          ),
          if (isLoading) const Loader(message: "Updating controller"),
        ],
      ),
    );
  }
}