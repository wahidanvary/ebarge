// Copyright (c) 2018, codegrue. All rights reserved. Use of this source code
// is governed by the MIT license that can be found in the LICENSE file.

import 'package:card_settings/helpers/platform_functions.dart';
import 'package:flutter/material.dart';
import 'package:my_cupertino_settings/my_cupertino_settings.dart';

import '../../interfaces/minimum_field_properties.dart';

/// This is a button widget for inclusion in the form.
class CardSettingsButton extends StatelessWidget
    implements IMinimumFieldSettings {
  CardSettingsButton({
    this.label = 'Label',
    required this.onPressed,
    this.visible = true,
    this.backgroundColor,
    this.textColor,
    this.enabled = true,
    this.bottomSpacing = 0.0,
    this.isDestructive = false,
    this.showMaterialonIOS,
  });

  /// The text to place in the button
  final String label;

  /// tells the Ui the button is destructive. Helps select color.
  final bool isDestructive;

  /// The background color for normal buttons
  final Color? backgroundColor;

  /// The text color for normal buttons
  final Color? textColor;

  /// allows adding extra padding at the bottom
  final double bottomSpacing;

  /// If false, grays out the field and makes it unresponsive
  final bool enabled;

  /// Force the widget to use Material style on an iOS device
  @override
  final bool? showMaterialonIOS;

  /// If false hides the widget on the card setting panel
  @override
  final bool visible;

  /// Fires when the button is pressed
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    TextStyle buttonStyle =
        Theme.of(context).textTheme.labelLarge!.copyWith(color: textColor);

    if (visible) {
      if (showCupertino(context, showMaterialonIOS))
        return _showCuppertinoButton();
      else
        return _showMaterialButton(context, buttonStyle);
    } else {
      return Container();
    }
  }

  Widget _showMaterialButton(BuildContext context, TextStyle buttonStyle) {
    

    // Define the default colors based on destructive state or provided colors
    final Color defaultBgColor =
    isDestructive ? Colors.red[700]! : (backgroundColor ?? Theme.of(context).primaryColor);
    final Color defaultTextColor = textColor ?? Colors.white;
    final Color disabledBgColor = Colors.grey[300]!;
    final Color disabledTextColor = Colors.grey[700]!;

    return Container(
      margin: EdgeInsets.only(
          top: 0.0, bottom: bottomSpacing, left: 6.0, right: 6.0),
      padding: EdgeInsets.all(0.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            // Background color for enabled state
            backgroundColor: defaultBgColor,
            // Text color for enabled state
            foregroundColor: defaultTextColor,
            // Background color for disabled state
            disabledBackgroundColor: disabledBgColor,
            // Text color for disabled state
            disabledForegroundColor: disabledTextColor,
            // Shape with rounded corners
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Consistent rounded corners
            ),
            // Adjust padding to center text visually if needed, though default is often good
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            // Elevation for the shadow effect
            elevation: 2.0, // Subtle shadow for a "lifted" look
            shadowColor: Colors.black.withOpacity(0.2), // Softer shadow color
          ),
          onPressed: enabled ? onPressed : null, // Disable button by passing null to onPressed
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16.0, // Slightly larger font size for better readability
              fontWeight: FontWeight.w600, // Semi-bold for emphasis
            ),
          ),
        ),
      ),
    );
  }

  Widget _showCuppertinoButton() {
    return Container(
      child: visible == false
          ? null
          : CSButton(
              isDestructive
                  ? CSButtonType.DESTRUCTIVE
                  : CSButtonType.DEFAULT_CENTER,
              label,
              onPressed,
            ),
    );
  }
}
