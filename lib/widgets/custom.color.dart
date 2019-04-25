import 'package:flutter/material.dart';

const _r = 0;
const _g = 128;
const _b = 64;
//const _darkGreen = 0xFF1B5E20;

Map<int, Color> color =
{
  50:Color.fromRGBO(_r,_g,_b, .1),
  100:Color.fromRGBO(_r,_g,_b, .2),
  200:Color.fromRGBO(_r,_g,_b, .3),
  300:Color.fromRGBO(_r,_g,_b, .4),
  400:Color.fromRGBO(_r,_g,_b, .5),
  500:Color.fromRGBO(_r,_g,_b, .6),
  600:Color.fromRGBO(_r,_g,_b, .7),
  700:Color.fromRGBO(_r,_g,_b, .8),
  800:Color.fromRGBO(_r,_g,_b, .9),
  900:Color.fromRGBO(_r,_g,_b, 1),
};

MaterialColor mainAppColor = MaterialColor(0xFF2E7D32, color);