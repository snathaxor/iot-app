import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/input.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/enum/access.enum.dart';
import 'package:iot/screens/addSchedule/components/heading.component.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/user.controller.dart';
import '../../util/functions.util.dart';

class SharingScreen extends StatefulWidget {
  final String deviceID;
  final String deviceName;

  const SharingScreen({
    Key? key,
    required this.deviceID,
    required this.deviceName,
  }) : super(key: key);

  @override
  State<SharingScreen> createState() => _SharingScreenState();
}

class _SharingScreenState extends State<SharingScreen> {
  late final TextEditingController textEditingController;

  bool isLoading = false;
  AccessType type = AccessType.guest;
  String? link;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  Future<void> generateLink(BuildContext ctonext) async {
    try {
      if (textEditingController.text.isEmpty) {
        throw "Please enter a nickname";
      }

      final UserController controller = Provider.of<UserController>(context, listen: false);
      final String? tempKey = await controller.addDevice(widget.deviceID, forSelf: false, accessType: type, nickName: textEditingController.text);

      if (tempKey == null) {
        throw "Failed to create a shareable link for the device";
      }

      final String _link = await generateDynamicLink('shareDevice?key=$tempKey');

      setState(() {
        link = _link;
      });

      showMessage(context, "Link generated successfully!");
    } catch (e) {
      showMessage(context, e.toString());
    }
  }

  Future<void> share(BuildContext context, String link) async {
    try {
      final UserController controller = Provider.of<UserController>(context, listen: false);
      final String name = controller.profile!.name;

      final String shareText = "$name has provided you access to the ${widget.deviceName}. Please follow the link: $link";
      await Share.share(shareText);
    } catch (e) {
      showMessage(context, "Failed to share the link: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sharing"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: AnimatedCrossFade(
              crossFadeState: link != null ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
              firstChild: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomInput(label: "Nickname", controller: textEditingController),
                  ListTile(
                    title: const CustomHeading(heading: "Access Type"),
                    trailing: DropdownButton<AccessType>(
                      value: type,
                      items: AccessType.values
                          .map(
                            (accessType) => DropdownMenuItem(
                              child: Text(accessType.value.capitalize()),
                              value: accessType,
                            ),
                          )
                          .toList(),
                      onChanged: (accessType) {
                        if (accessType == null) {
                          return;
                        }

                        setState(() {
                          type = accessType;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 50),
                  CustomButton(
                    text: "Create Shareable Link",
                    onPressed: () => generateLink(context),
                  ),
                ],
              ),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text(
                            "Share via QR code",
                            style: TextStyle(),
                          ),
                          const SizedBox(height: 10),
                          if (link != null)
                            QrImageView(
                              data: link!,
                              version: QrVersions.auto,
                              size: 200,
                            ),
                        ],
                      ),
                    ),
                  ),

                  /**
                 * End of top section
                 */

                  /**
                 * OR SEPERATOR
                 */
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("OR"),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  /**
                 * END OF OR SEPERATOR
                 */

                  /**
                 * Buttons to share
                 */
                  if (link != null)
                    CustomButton(
                      text: "Share via other methods",
                      onPressed: () => share(context, link!),
                    ),
                ],
              ),
            ),
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }
}
