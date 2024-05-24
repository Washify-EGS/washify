import 'package:flutter/material.dart';
import 'package:washify/constants.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({
    Key? key,
    required this.buttonText,
    this.icon,
    this.icon2,
    this.isOutlined = false,
    required this.onPressed,
    this.width = 280,
    this.height = 60,
    this.fontSize = 20,
  }) : super(key: key);

  final String buttonText;
  final IconData? icon;
  final IconData? icon2;
  final bool isOutlined;
  final Function onPressed;
  final double width;
  final double height;
  final double fontSize;

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: _isPressed
                ? Colors.grey[700]
                : (_isHovered
                    ? (widget.isOutlined ? Colors.grey[200] : Colors.grey[600])
                    : (widget.isOutlined ? Colors.white : kTextColor)),
            border: Border.all(
                color: _isPressed
                    ? Colors.grey[700]!
                    : (widget.isOutlined ? kTextColor : Colors.transparent),
                width: 2.5),
            borderRadius: BorderRadius.circular(30),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    )
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Align center
            children: [
              if (widget.icon2 != null)
                Icon(
                  widget.icon2,
                  color: widget.isOutlined ? kTextColor : Colors.white,
                ),
              Expanded(
                child: Text(
                  widget.buttonText,
                  textAlign: TextAlign.center, // Center text
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: widget.fontSize,
                    color: widget.isOutlined ? kTextColor : Colors.white,
                  ),
                ),
              ),
              if (widget.icon != null)
                Icon(
                  widget.icon,
                  color: widget.isOutlined ? kTextColor : Colors.white,
                ),
            ],
          ),
        ),
      ),
    );
  }
}