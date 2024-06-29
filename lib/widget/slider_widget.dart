import 'package:flutter/material.dart';


class SliderWidget extends StatefulWidget {
  final String label;
  final double initialValue;
  final double minValue;
  final double maxValue;
  final ValueChanged<double>? onChanged;

  SliderWidget({
    required this.label,
    this.initialValue = 0,
    this.minValue = -360,
    this.maxValue = 360,
    this.onChanged,
  });

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  late double _value;

  @override
  void initState() {
    super.initState();
    // _value = widget.initialValue;
    _value = widget.initialValue.clamp(widget.minValue, widget.maxValue); // Ensure value is within range
    if (_value < widget.minValue) {
      _value = widget.minValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _value,
            min: widget.minValue,
            max: widget.maxValue,
            divisions: ((widget.maxValue - widget.minValue) * 2).toInt(),
            label: _value.round().toString(),
            onChanged: (double value) {
              setState(() {
                _value = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
          ),
        ),
        Container(
          width: 50,
          child: Text(
            _value.round().toString(),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}