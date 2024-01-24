import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final double fontSize;
  final TextStyle style;
  final int maxLines;

  const ExpandableText({
    Key? key,
    required this.text,
    this.fontSize = 16.0,
    this.style = const TextStyle(color: Colors.black),
    this.maxLines = 3,
  }) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final span = TextSpan(
          text: widget.text,
          style: widget.style,
        );

        final tp = TextPainter(
          text: span,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        );

        tp.layout(maxWidth: constraints.maxWidth);

        if (tp.didExceedMaxLines) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (!isExpanded)
                Text(
                  widget.text,
                  style: widget.style,
                  maxLines: widget.maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              if (isExpanded)
                Text(
                  widget.text,
                  style: widget.style,
                ),
              TextButton(
                child: Text(isExpanded ? "Read Less" : "Read More"),
                onPressed: () => setState(() => isExpanded = !isExpanded),
              ),
            ],
          );
        } else {
          return Text(
            widget.text,
            style: widget.style,
          );
        }
      },
    );
  }
}
