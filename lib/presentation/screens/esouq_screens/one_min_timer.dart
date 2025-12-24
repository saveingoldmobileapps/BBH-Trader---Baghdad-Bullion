
import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/res_sizes/res.dart';
import '../../../core/theme/const_colors.dart';
import '../../../core/theme/get_generic_text_widget.dart';

class OneMinuteTimer extends StatefulWidget {
  final TextStyle? textStyle;
  final VoidCallback? onFinish;

  const OneMinuteTimer({
    super.key,
    this.textStyle,
    this.onFinish,
  });

  @override
  OneMinuteTimerState createState() => OneMinuteTimerState();
}

class OneMinuteTimerState extends State<OneMinuteTimer>
    with SingleTickerProviderStateMixin {
  int remainingSeconds = 60;
  Timer? timer;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.12)
        .chain(CurveTween(curve: Curves.easeOutBack))
        .animate(_controller);

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _colorAnimation = ColorTween(
      begin: AppColors.primaryGold500,
      end: Colors.redAccent,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0),
    ));

    startTimer();
  }

  // void startTimer() {
  //   timer = Timer.periodic(const Duration(seconds: 1), (t) {
  //     if (remainingSeconds <= 1) {
  //       t.cancel();
  //       widget.onFinish?.call();
  //     } else {
  //       setState(() => remainingSeconds--);

  //       /// Trigger animation every second
  //       _controller.forward(from: 0);
  //     }
  //   });
  // }
  void startTimer() {
  timer = Timer.periodic(const Duration(seconds: 1), (t) {
    if (remainingSeconds <= 1) {
      t.cancel();

      // Call parent callback
      widget.onFinish?.call();

      // Auto navigate back
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      setState(() => remainingSeconds--);

      _controller.forward(from: 0);
    }
  });
}


  void stopTimer() {
    timer?.cancel();
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final bool isEnding = remainingSeconds <= 10;

        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GetGenericText(
              text: "$remainingSeconds sec",
              fontSize: sizes!.responsiveFont(
                phoneVal: 18,
                tabletVal: 20,
              ),
              fontWeight: FontWeight.bold,
              color: isEnding
    ? (_colorAnimation.value ?? Colors.redAccent)
    : AppColors.primaryGold500,

              //color: isEnding ? _colorAnimation.value : AppColors.primaryGold500,
            ),
          ),
        );
      },
    );
  }
}

// import 'dart:async';

// import 'package:flutter/material.dart';

// import '../../../core/res_sizes/res.dart';
// import '../../../core/theme/const_colors.dart';
// import '../../../core/theme/get_generic_text_widget.dart';

// class OneMinuteTimer extends StatefulWidget {
//   final TextStyle? textStyle;
//   final VoidCallback? onFinish;

//   const OneMinuteTimer({
//     super.key,
//     this.textStyle,
//     this.onFinish,
//   });

//   @override
//   OneMinuteTimerState createState() => OneMinuteTimerState();
// }

// class OneMinuteTimerState extends State<OneMinuteTimer> {
//   int remainingSeconds = 60;
//   Timer? timer;

//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//   }

//   void startTimer() {
//     timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       if (remainingSeconds <= 1) {
//         t.cancel();
//         widget.onFinish?.call();
//       } else {
//         setState(() => remainingSeconds--);
//       }
//     });
//   }

//   //  Call this from button press
//   void stopTimer() {
//     timer?.cancel();
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetGenericText(
//       text: "$remainingSeconds sec",
//       fontSize: sizes!.responsiveFont(
//         phoneVal: 16,
//         tabletVal: 18,
//       ),
//       fontWeight: FontWeight.w600,
//       color:
//           remainingSeconds <= 5 ? Colors.redAccent : AppColors.primaryGold500,
//     );
//   }
// }
