///
/// Created by Giovanni Terlingen
/// See LICENSE file for more information.
///
import 'package:flutter/material.dart';
import 'package:bangladesh_map/map_svg_data.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Clickable SVG map of Bangladesh',
        theme: ThemeData(primarySwatch: Colors.blueGrey),
        home: MyHomePage(title: 'Clickable SVG map of Bangladesh'));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  District _pressedDistrict;

  @override
  Widget build(BuildContext context) {
    /// Calculate the center point of the SVG map,
    /// use parent widget for width/heigth.
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double navBarHeight =
        Theme.of(context).platform == TargetPlatform.android ? 56.0 : 44.0;
    double safeZoneHeight = MediaQuery.of(context).padding.bottom;

    double scaleFactor = 3.5;

    double x = (width / 2.0) - (MapSvgData.width / 2.0);
    double y = (height / 2.0) -
        (MapSvgData.height / 2.0) -
        (safeZoneHeight / 2.0) -
        navBarHeight;
    Offset offset = Offset(x, y);

    return Scaffold(
      appBar: AppBar(title: Text('Districts of Bangladesh')),
      body: SafeArea(
        child: Transform.scale(
          scale: ((height / MapSvgData.height)) * scaleFactor,
          child: Transform.translate(
              offset: offset,
              child: Container(
                color: Colors.blueGrey,
                child: Stack(
                  children: _buildMap(),
                ),
              )),
        ),
      ),
    );
  }

  List<Widget> _buildMap() {
    List<Widget> districts = List(District.values.length);
    for (int i = 0; i < District.values.length; i++) {
      districts[i] = _buildDistrict(District.values[i]);
    }
    return districts;
  }

  Widget _buildDistrict(District district) {
    return ClipPath(
        child: Stack(children: <Widget>[
          CustomPaint(painter: PathPainter(district)),
          Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () => _districtPressed(district),
                  child: Container(
                      color: _pressedDistrict == district
                          ? Color(0xFF7C7C7C)
                          : Colors.transparent)))
        ]),
        clipper: PathClipper(district));
  }

  void _districtPressed(District district) {
    setState(() {
      _pressedDistrict = district;
    });
  }
}

class PathPainter extends CustomPainter {
  final District _district;
  PathPainter(this._district);

  @override
  void paint(Canvas canvas, Size size) {
    Path path = getPathByDistrict(_district);
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.black
          ..strokeWidth = 2.0);
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(PathPainter oldDelegate) => false;
}

class PathClipper extends CustomClipper<Path> {
  final District _district;
  PathClipper(this._district);

  @override
  Path getClip(Size size) {
    return getPathByDistrict(_district);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
