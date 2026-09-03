import 'package:get/get.dart';
import 'package:poty_ia_app/ui/cadastro/cadastro_controller.dart';
import 'package:poty_ia_app/ui/cadastro/cadastro_page.dart';
import 'package:poty_ia_app/ui/home/home_page.dart';
import 'package:poty_ia_app/ui/login/login_controller.dart';
import 'package:poty_ia_app/ui/login/login_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: BindingsBuilder(() {
        Get.put(LoginController());
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
    ),
    GetPage(
      name: AppRoutes.cadastro,
      page: () => const CadastroPage(),
      binding: BindingsBuilder(() {
        Get.put(CadastroController());
      }),
    ),
  ];
}

class AuthRepository {}
