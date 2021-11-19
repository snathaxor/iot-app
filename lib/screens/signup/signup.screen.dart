import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/input.component.dart';
import 'package:iot/components/link.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/screens/signup/components/dropdown.component.dart';
import 'package:iot/util/constants.util.dart';
import 'package:iot/util/functions.util.dart';
import 'package:iot/util/themes.util.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:country_picker/country_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late TextEditingController email;
  late TextEditingController password;
  late TextEditingController confirmPassword;
  late TextEditingController firstName;
  late TextEditingController lastName;
  late TextEditingController phone;
  bool isAgreed = false;
  Country? pickedCountry;

  String emailError = '';
  String passwordError = '';
  String confirmPasswordError = '';
  String firstNameError = '';
  String lastNameError = '';
  String phoneError = '';
  String tosError = '';
  String countryError = '';
  String formError = '';

  bool isLoading = false;

  final GlobalKey<FormFieldState> formKey = GlobalKey<FormFieldState>();

  Future<void> openTermsOfUse(BuildContext context) async {
    try {
      if (await canLaunch(linkToTermsOfUse)) {
        await launch(linkToTermsOfUse);
      }
    } catch (e) {
      showMessage(context, "Failed to open terms of use");
    }
  }

  @override
  void initState() {
    super.initState();
    email = TextEditingController();
    password = TextEditingController();
    confirmPassword = TextEditingController();
    firstName = TextEditingController();
    lastName = TextEditingController();
    phone = TextEditingController();
  }

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

  bool validateFirstName() {
    if (firstName.text == "") {
      setState(() {
        firstNameError = "First name cannot be empty!";
      });

      return false;
    }

    if (firstNameError != '') {
      setState(() {
        firstNameError = '';
      });
    }

    return true;
  }

  bool validateLastName() {
    if (lastName.text == "") {
      setState(() {
        lastNameError = "First name cannot be empty!";
      });

      return false;
    }

    if (lastNameError != '') {
      setState(() {
        lastNameError = '';
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
    } else if (password.text.length < 6) {
      setState(() {
        passwordError = "Password must be atleast 6 characters in length!";
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

  bool validateConfirmPassword() {
    if (confirmPassword.text == "") {
      setState(() {
        confirmPasswordError = "Password cannot be empty!";
      });

      return false;
    } else if (confirmPassword.text != password.text) {
      setState(() {
        confirmPasswordError = "Passwords must match!";
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

  bool validatePhone() {
    if (phone.text == '') {
      setState(() {
        phoneError = "Phone number must not be empty!";
      });

      return false;
    } else if (int.tryParse(phone.text) == null) {
      setState(() {
        phoneError = "Phone number must be valid!";
      });

      return false;
    }

    if (phoneError != '') {
      setState(() {
        phoneError = '';
      });
    }

    return true;
  }

  bool validateCountry() {
    if (pickedCountry == null) {
      setState(() {
        countryError = "Please select a country!";
      });

      return false;
    }

    if (countryError != '') {
      setState(() {
        countryError = '';
      });
    }

    return true;
  }

  Future<void> signup(BuildContext context) async {
    try {
      final bool isEmailValid = validateEmail();
      final bool isPasswordValid = validatePassword();
      final bool isConfirmPasswordValid = validateConfirmPassword();
      final bool isFirstNameValid = validateFirstName();
      final bool isLastNameValid = validateLastName();
      final bool isPhoneValid = validatePhone();
      final bool isCountryValid = validateCountry();
      final bool isTOSAgreed = validateTOS();

      if (!isEmailValid ||
          !isFirstNameValid ||
          !isLastNameValid ||
          !isPhoneValid ||
          !isCountryValid ||
          !isConfirmPasswordValid | !isPasswordValid ||
          !isTOSAgreed) {
        return;
      }

      setState(() {
        isLoading = true;
      });

      FocusScope.of(context).unfocus();

      final bool success = await Provider.of<UserController>(context, listen: false).register(
        email.text,
        password.text,
        firstName.text,
        lastName.text,
        pickedCountry!.phoneCode,
        phone.text,
      );

      if (!success) {
        throw Exception("Failed to register the user");
      }

      showMessage(context, "Account created successfully!");
      Navigator.pushNamedAndRemoveUntil(context, Screen.dashboard, (route) => false);
    } on FirebaseAuthException catch (e) {
      showMessage(context, "Failed to create the account");
      setState(() {
        isLoading = false;
        formError = e.message != null ? e.message! : "Failed to complete the signup process";
      });
    } catch (e) {
      showMessage(context, "Failed to create the account");
      setState(() {
        isLoading = false;
        formError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Create An Account',
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
                              icon: Icons.email,
                              label: "Email Address *",
                              controller: email,
                              error: emailError,
                            ),
                            const SizedBox(height: 12.5),
                            CustomInput(
                              icon: Icons.lock,
                              label: "Password *",
                              isPassword: true,
                              controller: password,
                              error: passwordError,
                            ),
                            const SizedBox(height: 12.5),
                            CustomInput(
                              icon: Icons.lock,
                              label: "Confirm Password *",
                              isPassword: true,
                              controller: confirmPassword,
                              error: confirmPasswordError,
                            ),
                            const SizedBox(height: 12.5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: CustomInput(
                                    icon: Icons.person,
                                    label: "First Name *",
                                    controller: firstName,
                                    error: firstNameError,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: CustomInput(
                                    icon: Icons.person,
                                    label: "Last Name *",
                                    controller: lastName,
                                    error: lastNameError,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 0.5,
                              color: textColor.withOpacity(0.5),
                              margin: const EdgeInsets.symmetric(vertical: 12.5),
                            ),
                            Column(
                              children: [
                                CustomDropDown(
                                  onPressed: () {
                                    showCountryPicker(
                                      context: context,
                                      showPhoneCode: true,
                                      onSelect: (country) {
                                        setState(() {
                                          pickedCountry = country;
                                        });
                                      },
                                    );
                                  },
                                  icon: Icons.flag,
                                  text: pickedCountry == null ? "Country *" : pickedCountry!.displayNameNoCountryCode,
                                ),
                                if (countryError != '')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.5),
                                    child: Text(
                                      countryError,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12.5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomDropDown(
                                  onPressed: () {
                                    showCountryPicker(
                                      context: context,
                                      onSelect: (country) {
                                        pickedCountry = country;
                                      },
                                    );
                                  },
                                  text: pickedCountry == null ? '-' : pickedCountry!.phoneCode,
                                  icon: Icons.flag,
                                ),
                                const SizedBox(width: 12.5),
                                Expanded(
                                  child: CustomInput(
                                    label: "Phone number",
                                    controller: phone,
                                    error: phoneError,
                                    onDone: () {
                                      signup(context);
                                    },
                                  ),
                                ),
                              ],
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
                                  const Text("By Registering, I agree to "),
                                  LinkButton(
                                    onPressed: () {
                                      openTermsOfUse(context);
                                    },
                                    text: "Terms of Use.",
                                    color: authPrimaryColor,
                                  ),
                                ],
                              ),
                            ),
                            CustomButton(
                              text: "Register",
                              onPressed: () {
                                signup(context);
                              },
                            ),
                          ],
                        ),
                      ),
                      /**
                       * End of form section
                       */

                      const SizedBox(height: 50),

                      /**
                       * Bottom Section
                       */
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 5),
                          LinkButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(context, Screen.login, (route) => false);
                            },
                            text: "Login",
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      /**
                       * End of bottom section
                       */
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }
}
