import 'package:flutter/material.dart';
import '../../domain/model/alert_type.dart';

class VietnamTrafficSign extends StatelessWidget {
  final AlertType type;
  final String? label;
  final double size;
  const VietnamTrafficSign({super.key, required this.type, this.label, this.size = 36});

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: CustomPaint(painter: _SignPainter(type, label)));
}

class _SignPainter extends CustomPainter {
  final AlertType type;
  final String? label;
  _SignPainter(this.type, this.label);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = size.shortestSide / 2;
    final strokeWidth = radius * 0.2;

    switch (type) {
      case AlertType.speedCamera: case AlertType.trafficLight: case AlertType.noOvertakingStart:
      case AlertType.speedSign: case AlertType.noParking: case AlertType.noEntry:
      case AlertType.noTurn: case AlertType.noUTurn:
        final strokePaint = Paint()..color = const Color(0xFFE53935)..style = PaintingStyle.stroke..strokeWidth = strokeWidth;
        canvas.drawCircle(center, radius - strokeWidth / 2, Paint()..color = Colors.white);
        canvas.drawCircle(center, radius, strokePaint);

        if (type == AlertType.speedSign && label != null) {
          final tp = TextPainter(text: TextSpan(text: label, style: TextStyle(color: Colors.black, fontSize: h * 0.45, fontWeight: FontWeight.w900)), textDirection: TextDirection.ltr)..layout();
          tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
        } else if (type == AlertType.speedCamera) {
          canvas.drawRect(Rect.fromLTWH(w * 0.25, h * 0.38, w * 0.45, h * 0.25), Paint()..color = const Color(0xFF555555));
          canvas.drawCircle(Offset(w * 0.63, h * 0.53), h * 0.07, Paint()..color = Colors.black);
        } else if (type == AlertType.trafficLight) {
          canvas.drawRect(Rect.fromLTWH(w * 0.4, h * 0.25, w * 0.2, h * 0.5), Paint()..color = Colors.black);
          canvas.drawCircle(Offset(w * 0.5, h * 0.35), radius * 0.1, Paint()..color = Colors.red);
        } else {
          final symbol = switch (type) { AlertType.noParking => 'P', AlertType.noEntry => 'X', AlertType.noTurn => 'T', AlertType.noUTurn => 'U', _ => '!' };
          final tp = TextPainter(text: TextSpan(text: symbol, style: TextStyle(color: Colors.black, fontSize: h * 0.25, fontWeight: FontWeight.w900)), textDirection: TextDirection.ltr)..layout();
          tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
          canvas.drawLine(Offset(w * 0.25, h * 0.75), Offset(w * 0.75, h * 0.25), Paint()..color = const Color(0xFFE53935)..strokeWidth = strokeWidth * 0.8);
        }
      case AlertType.infoSign:
        canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8), Paint()..color = const Color(0xFF1565C0));
        final tp = TextPainter(text: TextSpan(text: 'i', style: TextStyle(color: Colors.white, fontSize: h * 0.5, fontWeight: FontWeight.w900)), textDirection: TextDirection.ltr)..layout();
        tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
      default:
        final path = Path()..moveTo(w * 0.5, h * 0.1)..lineTo(w * 0.9, h * 0.85)..lineTo(w * 0.1, h * 0.85)..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFFFFD600));
        canvas.drawPath(path, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant _SignPainter old) => old.type != type || old.label != label;
}
