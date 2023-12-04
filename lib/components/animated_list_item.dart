import 'package:flutter/widgets.dart';

class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final bool animateOnce;
  final Duration duration;

  const AnimatedListItem(
      {Key? key,
      required this.child,
      required this.animateOnce,
      required this.duration})
      : super(key: key);

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with AutomaticKeepAliveClientMixin {
  bool _animate = false;

  static bool _isStart = true;

  @override
  void initState() {
    super.initState();
    if (widget.animateOnce) {
      if (_isStart) {
        Future.delayed(widget.duration, () {
          setState(() {
            _animate = true;
            _isStart = false;
          });
        });
      } else {
        _animate = true;
      }
    } else {
      Future.delayed(widget.duration, () {
        setState(() {
          _animate = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _animate ? 1 : 0,
      curve: Curves.easeInOutQuart,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 500),
        padding: _animate
            ? const EdgeInsets.fromLTRB(16, 8, 16, 0)
            : const EdgeInsets.all(30.0),
        child: widget.child,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
