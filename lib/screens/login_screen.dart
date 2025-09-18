import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; // 👈 AQUÍ LE MODIFIQUÉ (para usar Timer)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Cerebro de la lógica de animación
  StateMachineController? controller;

  SMIBool? isChecking; //Activar al Oso chismoso
  SMIBool? isHandsUp; //Se tapa los ojos
  SMITrigger? trigSuccess; //Se emociona
  SMITrigger? trigFail; //Se pone muy sad

  //Variable para mover los ojos:
  SMINumber? numLook;

  //Nueva variable para controlar la visibilidad de la contraseña
  bool isPasswordVisible = false;

  // 👈 AQUÍ LE MODIFIQUÉ (focus para los TextFields)
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  // 👈 AQUÍ LE MODIFIQUÉ (debounce timer para detectar cuando deja de escribir)
  Timer? typingTimer;

  // 👇 NUEVO: variables para guardar email y password
  String emailInput = '';
  String passwordInput = '';

  @override
  void initState() {
    super.initState();

    // 👈 AQUÍ LE MODIFIQUÉ (listener cuando email pierde el foco)
    emailFocusNode.addListener(() {
      if (!emailFocusNode.hasFocus) {
        if (isChecking != null) isChecking!.change(false);
      }
    });

    // 👈 AQUÍ LE MODIFIQUÉ (listener para password: tapar ojos al entrar, bajarlos al salir)
    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus) {
        if (isHandsUp != null) isHandsUp!.change(true);
      } else {
        if (isHandsUp != null) isHandsUp!.change(false);
      }
    });
  }

  @override
  void dispose() {
    // 👈 AQUÍ LE MODIFIQUÉ (limpiar FocusNode y Timer)
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Para obtener el tamaño de pantalla del dispositivo
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'animated_login_character.riv',
                  stateMachines: ["Login Machine"],
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(
                      artboard,
                      "Login Machine",
                    );
                    if (controller == null) return;
                    artboard.addController(controller!);
                    isChecking = controller!.findSMI('isChecking');
                    isHandsUp = controller!.findSMI('isHandsUp');
                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('trigFail');

                    numLook = controller!.findSMI('numLook');
                  },
                ),
              ),
              const SizedBox(height: 10),
              //Email
              TextField(
                focusNode: emailFocusNode, // 👈 AQUÍ LE MODIFIQUÉ
                onChanged: (value) {
                  emailInput = value; // 👈 Guardamos el valor del email

                  if (isHandsUp != null) {
                    isHandsUp!.change(false);
                  }
                  if (isChecking == null) return;
                  isChecking!.change(true);

                  if (numLook != null) {
                    double lookValue = (value.length.clamp(0, 80)) * 1.5;
                    numLook!.change(lookValue);
                  }

                  // 👈 AQUÍ LE MODIFIQUÉ (debounce: cuando deje de escribir, deja de mirar)
                  typingTimer?.cancel();
                  typingTimer = Timer(const Duration(seconds: 2), () {
                    if (isChecking != null) isChecking!.change(false);
                  });
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              //Password
              TextField(
                focusNode: passwordFocusNode, // 👈 AQUÍ LE MODIFIQUÉ
                onChanged: (value) {
                  passwordInput = value; // 👈 Guardamos el valor del password

                  if (isChecking != null) {
                    isChecking!.change(false);
                  }
                  if (isHandsUp == null) return;
                  isHandsUp!.change(true);
                },
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: const Text(
                  "Forgot your Password?",
                  textAlign: TextAlign.right,
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 10),
              MaterialButton(
                minWidth: size.width,
                height: 50,
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: () {
                  FocusScope.of(
                    context,
                  ).unfocus(); // 👈 Cierra teclado al presionar Login

                  // 👇 LÓGICA PARA trigSuccess Y trigFail
                  const correctEmail = 'jdcs2303201@gmail.com';
                  const correctPassword = 'Jair123';

                  if (emailInput == correctEmail &&
                      passwordInput == correctPassword) {
                    // Si ambos son correctos → éxito
                    if (trigSuccess != null) trigSuccess!.fire();
                  } else {
                    // Si alguno falla → fracaso
                    if (trigFail != null) trigFail!.fire();
                  }
                },
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
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
