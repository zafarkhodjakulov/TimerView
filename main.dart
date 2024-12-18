import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(TimerApp());

class TimerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Timer',
      home: TimerPage(),
    );
  }
}

class TimerPage extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _timeInSeconds = 60; // Boshlang‘ich vaqt
  int _remainingTime = 60; // Qolgan vaqt
  bool _isRunning = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _timeInSeconds),
    );
  }

  void _startCountdown() {
    if (_isRunning || _remainingTime <= 0) return;
    setState(() => _isRunning = true);
    _animationController.reverse(from: _remainingTime / _timeInSeconds);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _stopCountdown();
          _showCompletionDialog();
        }
      });
    });
  }

  void _stopCountdown() {
    if (_timer.isActive) _timer.cancel();
    _animationController.stop();
    setState(() => _isRunning = false);
  }

  void _resetCountdown({int newTime = 60}) {
    _stopCountdown();
    setState(() {
      _timeInSeconds = newTime;
      _remainingTime = newTime;
      _animationController.duration = Duration(seconds: newTime);
    });
    _animationController.reset();
  }

  void _showCompletionDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Vaqt tugadi!'),
        content: Text('Taymer o‘z ishini yakunladi.'),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              _resetCountdown();
            },
          ),
        ],
      ),
    );
  }

  void _showTimePickerDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text('Vaqtni tanlang'),
          message: Container(
            height: 150,
            child: CupertinoTimerPicker(
              initialTimerDuration: Duration(seconds: _timeInSeconds),
              mode: CupertinoTimerPickerMode.ms,
              onTimerDurationChanged: (Duration newDuration) {
                setState(() {
                  _timeInSeconds = newDuration.inSeconds;
                  _remainingTime = _timeInSeconds;
                  _animationController.duration = newDuration;
                });
              },
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Saqlash'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    if (_timer.isActive) _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int minutes = (_remainingTime ~/ 60);
    int seconds = (_remainingTime % 60);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Timer'),
        trailing: GestureDetector(
          onTap: _showTimePickerDialog,
          child: Icon(CupertinoIcons.timer),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Taymer progress bar
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 250,
                    width: 250,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return CircularProgressIndicator(
                          value: _animationController.value,
                          strokeWidth: 12,
                          backgroundColor: CupertinoColors.systemGrey4,
                          valueColor: AlwaysStoppedAnimation(
                              CupertinoColors.activeBlue),
                        );
                      },
                    ),
                  ),
                  Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 50),

            // Tugmalar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Start tugmasi
                CupertinoButton(
                  color: CupertinoColors.activeGreen,
                  child: Text(
                    'Start',
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: _startCountdown,
                ),

                // Stop tugmasi
                CupertinoButton(
                  color: CupertinoColors.systemRed,
                  child: Text(
                    'Stop',
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: _stopCountdown,
                ),

                // Reset tugmasi
                CupertinoButton(
                  color: CupertinoColors.systemYellow,
                  child: Text(
                    'Reset',
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () => _resetCountdown(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
