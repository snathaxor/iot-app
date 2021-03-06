import 'package:flutter/material.dart';
import '/components/button.component.dart';
import '/components/input.component.dart';
import '/components/link.component.dart';
import '/components/loader.component.dart';
import '/controllers/user.controller.dart';
import '/enum/route.enum.dart';
import '/util/constants.util.dart';
import '/util/functions.util.dart';
import '/util/themes.util.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// TextEditingControllers and Form state
  /// Each of the controller is used to control the input fields on the
  /// page - isAgreed boolean is used to control the state of whether the user
  /// has accepted the terms of service or not
  /// isLoading - controls whether to show or hide the loading indicator
  late TextEditingController email;
  late TextEditingController password;
  bool isAgreed = true;
  bool isLoading = false;

  /// Error holders
  String emailError = '';
  String passwordError = '';
  String tosError = '';
  String formError = '';

  /// Focus Nodes
  late final FocusNode tosFocusNode;

  /// Extraneous variables
  final GlobalKey<FormFieldState> formKey = GlobalKey<FormFieldState>();

  /// initializers and disposers
  @override
  void initState() {
    super.initState();

    /**
     * Initializing the editing controllers and focus nodes
     */
    email = TextEditingController();
    password = TextEditingController();

    tosFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();

    /**
     * Disposing the controllers and focus nodes
     */
    email.dispose();
    password.dispose();

    tosFocusNode.dispose();
  }

  /// Functions
  Future<void> openTermsOfUse(BuildContext context) async {
    try {
      if (await canLaunch(linkToTermsOfUse)) {
        await launch(linkToTermsOfUse);
      }
    } catch (e) {
      showMessage(context, "Failed to open terms of use");
    }
  }

  /// *************************************************************************** ///
  /// Validation methods
  bool validateEmail() {
    if (email.text == "") {
      setState(() {
        emailError = "Email cannot be empty!";
      });

      return false;
    }

    if (emailError != '') {
      setState(() {
        emailError = '';
      });
    }

    return true;
  }

  bool validatePassword() {
    if (password.text == "") {
      setState(() {
        passwordError = "Password cannot be empty!";
      });
      return false;
    }

    if (passwordError != '') {
      setState(() {
        passwordError = '';
      });
    }
    return true;
  }

  bool validateTOS() {
    if (!isAgreed) {
      setState(() {
        tosError = "You need to agree to Terms of Service to continue";
      });

      return false;
    }

    if (tosError != '') {
      setState(() {
        tosError = '';
      });
    }

    return true;
  }

  /// ***********************************************************************************///
  /// End of validation methods

  Future<void> login(BuildContext context) async {
    try {
      /**
       * Validate each item and if either is invalid then return
       */
      final bool isEmailValid = validateEmail();
      final bool isPasswordValid = validatePassword();
      final bool isTOSAgreed = validateTOS();

      if (!isEmailValid || !isPasswordValid || !isTOSAgreed) {
        return;
      }

      setState(() {
        isLoading = true;
      });

      FocusScope.of(context).unfocus();

      /// Made nullable to handle the third state
      /// 1. true means logged in successfully
      /// 2. false means the user was not logged in
      /// 3. null means the user was logged in but email needs verification
      final bool? success = await Provider.of<UserController>(context, listen: false).login(email.text.trim(), password.text);

      if (success == null) {
        Navigator.pushNamedAndRemoveUntil(context, Screen.success, (route) => false, arguments: true);
      }

      showMessage(context, "Logged in successfully!");
      Navigator.pushNamedAndRemoveUntil(context, Screen.dashboard, (route) => false);
    } catch (e) {
      setState(() {
        isLoading = false;
        formError = e.toString();
      });
      showMessage(context, "Login failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 100,
                  ),

                  /**
                       * Top Section
                       */
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 120,
                      maxWidth: 120,
                    ),
                    child: Image.asset(
                      'assets/icons/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  /**
                   * End of top section
                   */

                  const SizedBox(
                    height: 75,
                  ),

                  /**
                   * Form Section
                   */
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Login',
                          style: Theme.of(context).textTheme.headline5?.copyWith(
                                color: Colors.black,
                              ),
                        ),
                        const SizedBox(height: 20),
                        if (formError != '')
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              formError,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        CustomInput(
                          icon: Icons.person,
                          error: emailError,
                          label: "Email Address",
                          controller: email,
                          textInputType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12.5),
                        CustomInput(
                          icon: Icons.lock,
                          label: "Password",
                          isPassword: true,
                          error: passwordError,
                          controller: password,
                          onDone: () {
                            login(context);
                          },
                        ),
                        const SizedBox(height: 12.5),
                        Align(
                          alignment: Alignment.centerRight,
                          child: LinkButton(
                            onPressed: () {
                              Navigator.pushNamed(context, Screen.forgotPassword);
                            },
                            text: "Forgot Password?",
                          ),
                        ),
                        const SizedBox(height: 50),
                        if (tosError != '')
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Text(
                              tosError,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isAgreed = !isAgreed;
                            });
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                value: isAgreed,
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }

                                  setState(() {
                                    isAgreed = value;
                                  });
                                },
                              ),
                              const Text("By Signing in, I agree to "),
                              LinkButton(
                                onPressed: () {
                                  openTermsOfUse(context);
                                },
                                text: "Terms of Use",
                                color: authPrimaryColor,
                              ),
                            ],
                          ),
                        ),
                        CustomButton(
                          text: "Login",
                          onPressed: () {
                            login(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  /**
                       * End of form section
                       */

                  /**
               * Bottom Section
               */
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Don't have an account?",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        CustomButton(
                          text: "Create an Account",
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(Screen.signup, (_) => false);
                          },
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  /**
                   * End of bottom section
                   */
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
