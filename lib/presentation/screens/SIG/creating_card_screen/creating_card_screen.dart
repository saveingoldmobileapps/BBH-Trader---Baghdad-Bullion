import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/screens/SIG/creating_card_screen/sig_card_ui.dart';

class CreatingCardScreen extends ConsumerStatefulWidget {
  const CreatingCardScreen({super.key});

  @override
  ConsumerState createState() => _SigHomePageState();
}

class _SigHomePageState extends ConsumerState<CreatingCardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 5), () {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CardScreen(),
          ),
        );
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/png/bg_start.png'),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoActivityIndicator(
                radius: 25,
                color: AppColors.primaryGold500,
              ),
              ConstPadding.sizeBoxWithHeight(height: 10),
              GetGenericText(
                text: "Please wait while we create your card",
                fontSize: sizes!.isPhone ? 18 : 24,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ],
          ).get16HorizontalPadding(),
        ),
      ),
    );
  }
}
