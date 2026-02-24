import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/app/router.dart';
import 'package:neomoney/cloacka/features/app_start/cubit/app_start_cubit.dart';
import 'package:neomoney/cloacka/features/app_start/cubit/app_start_state.dart';
import 'package:neomoney/cloacka/features/app_start/screen/splash_screnn.dart';
import 'package:neomoney/cloacka/app/router/app_routes.dart';

class AppStartGate extends StatefulWidget {
  const AppStartGate({super.key});

  @override
  State<AppStartGate> createState() => _AppStartGateState();
}

class _AppStartGateState extends State<AppStartGate> {
  static const _minSplash = Duration(milliseconds: 700);
  static const _fade = Duration(milliseconds: 250);

  final Stopwatch _sw = Stopwatch()..start();
  double _opacity = 1.0;
  bool _navigated = false;

  late final AppStartCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AppStartCubit>();
    _cubit.bootstrap();
  }

  @override
  void dispose() {
    _cubit.close(); // важно, если кубит не singleton
    super.dispose();
  }

  Future<void> _goNext(String route) async {
    if (_navigated) return;
    _navigated = true;

    final remaining = _minSplash - _sw.elapsed;
    if (remaining > Duration.zero) await Future.delayed(remaining);

    if (!mounted) return;

    setState(() => _opacity = 0.0);
    await Future.delayed(_fade);

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<AppStartCubit, AppStartState>(
        listener: (context, state) {
          if (state is AppStartLoaded) {
            _goNext(state.nextRoute);
          } else if (state is AppStartError) {
            _goNext(AppRoutesCloacka.phoneAuth);
          }
        },
        child: SplashScreen(opacity: _opacity),
      ),
    );
  }
}