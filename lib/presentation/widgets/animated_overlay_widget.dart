import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessAnimationOverlay extends StatefulWidget {
  // final String message;
  final Duration displayDuration;
  final VoidCallback? onAnimationComplete;

  const SuccessAnimationOverlay({
    super.key,
    // required this.message,
    this.displayDuration = const Duration(seconds: 2),
    this.onAnimationComplete,
  });

  // Static method to show the animation from anywhere
  static void show({
    required BuildContext context,
    required String message,
    Duration displayDuration = const Duration(seconds: 2),
    VoidCallback? onComplete,
  }) {
    // Declare the variable first
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => SuccessAnimationOverlay(
        // message: message,
        displayDuration: displayDuration,
        onAnimationComplete: () {
          overlayEntry.remove();
          onComplete?.call();
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  @override
  State<SuccessAnimationOverlay> createState() => _SuccessAnimationOverlayState();
}

class _SuccessAnimationOverlayState extends State<SuccessAnimationOverlay> 
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    // Start the animation
    _controller.forward();

    // Wait for display duration
    await Future.delayed(widget.displayDuration);

    // Reverse animation for smooth exit
    await _controller.reverse();

    // Call completion callback
    widget.onAnimationComplete?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: Stack(
          children: [
            // Full screen Lottie animation
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Lottie.asset(
                'assets/lottie/Confetti.json',
                controller: _controller,
                fit: BoxFit.cover, // Changed to cover to fill entire screen
              ),
            ),
            
            // Message container on top
            // Center(
            //   child: Container(
            //     margin: const EdgeInsets.all(20),
            //     padding: const EdgeInsets.all(24),
            //     decoration: BoxDecoration(
            //       color: const Color(0xFF1E1E1E).withOpacity(0.92),
            //       borderRadius: BorderRadius.circular(20),
            //       border: Border.all(color: const Color(0xFFD4B77D), width: 1.5),
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.black.withOpacity(0.4),
            //           blurRadius: 25,
            //           offset: const Offset(0, 10),
            //         ),
            //       ],
            //     ),
            //     child: Column(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         // Success Message
            //         Text(
            //           widget.message,
            //           textAlign: TextAlign.center,
            //           style: const TextStyle(
            //             fontSize: 16,
            //             fontWeight: FontWeight.w500,
            //             color: Colors.white,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
         
          ],
        ),
      ),
    );
  }
}