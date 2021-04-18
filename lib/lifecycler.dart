import 'package:flutter/widgets.dart';

export 'package:flutter/widgets.dart' show AppLifecycleState;

//https://stackoverflow.com/questions/52074265/flutter-detect-killing-off-the-app/52074534

//typedef Future<void> LifecycleCallback(AppLifecycleState state);
typedef void LifecycleCallback(AppLifecycleState state);
typedef Future<void> FutureVoidCallback();

void bindLifecycleHandlers(
    {LifecycleCallback? onState,

    // перед тем, как приложение будет закрыто юзером, оно обязательно пройдет через состояние paused
    VoidCallback? onPaused,
    VoidCallback? onResumed,
    VoidCallback? onSuspending,
    VoidCallback? onInactive}) {
  var lo = LifecycleObserver(
      onState: onState,
      onPaused: onPaused,
      onResumed: onResumed,
      onSuspending: onSuspending,
      onInactive: onInactive);

  //#WidgetsBinding.instance.rem

  WidgetsBinding.instance?.addObserver(lo);
}

class LifecycleObserver extends WidgetsBindingObserver {
  LifecycleObserver(
      {this.onState, this.onPaused, this.onResumed, this.onSuspending, this.onInactive});

  final LifecycleCallback? onState;
  final VoidCallback? onPaused;
  final VoidCallback? onInactive;
  final VoidCallback? onResumed;
  final VoidCallback? onSuspending;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    print('''
=============================================================
               $state
=============================================================
''');

    this.onState?.call(state);

    //#if state

    switch (state) {
      case AppLifecycleState.inactive:
        this.onInactive?.call();
        break;
      case AppLifecycleState.paused:
        this.onPaused?.call();
        break;
      case AppLifecycleState.resumed:
        this.onResumed?.call();
        break;
      // тут было AppLifecycleState.suspending, но в новой версии Flutter такой константы нет
      case AppLifecycleState.detached:
        this.onSuspending?.call();
        break;
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class LifecycleObserving extends StatefulWidget {
  // этот виджет опционален: можно слушать состояния приложения и без встраивания в дерево.
  // Но если я хочу пристроиться к жизненному циклу ...

  LifecycleObserving({required this.child, this.onState, this.onInit, this.onDispose});

  final Widget child;
  final LifecycleCallback? onState;
  final VoidCallback? onInit;
  final VoidCallback? onDispose;

  @override
  _LifecycleObservingState createState() => _LifecycleObservingState();
}

class _LifecycleObservingState extends State<LifecycleObserving> {
  LifecycleObserver? _lo;

  @override
  void initState() {
    super.initState();
    this._lo = LifecycleObserver(onState: (x) => this.widget.onState?.call(x));
    WidgetsBinding.instance!.addObserver(this._lo!);
    this.widget.onInit?.call();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this._lo!);
    this._lo = null;
    this.widget.onDispose?.call();
  }

  @override
  Widget build(BuildContext context) {
    return this.widget.child;
  }
}
