import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/locator.dart';

class LanguageDropdown extends StatelessWidget {
  final AppTheme appTheme = locator<AppTheme>();
  final Function(String?) onChanged;
  final String value;

  final languages = [
    ['English', 'en'],
    ['ภาษาไทย', 'th'],
    ['ភាសាខ្មែរ', 'km'],
    ['ພາສາລາວ', 'lo'],
  ];

  LanguageDropdown({super.key, required this.onChanged, required this.value});

  @override
  Widget build(BuildContext context) {
    var currentTheme = Theme.of(context);
    return Theme(
      data: currentTheme.copyWith(
        inputDecorationTheme: currentTheme.inputDecorationTheme.copyWith(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appTheme.sub4, width: 1.0),
            borderRadius: BorderRadius.circular(60.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appTheme.sub4, width: 1.0),
            borderRadius: BorderRadius.circular(60.0),
          ),
        ),
      ),
      child: SizedBox(
        height: 24,
        child: DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: InputDecoration(
              // labelText: AppLocalizations.of(context)!.laguageLabel,
              contentPadding: const EdgeInsets.symmetric(vertical: 4.5),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(60.0),
              ),
              prefixIcon: Icon(
                Icons.language_outlined,
                size: 24,
                color: appTheme.primary,
              ),
            ),
            hint: const Text("Language"),
            value: value,
            onChanged: onChanged,
            selectedItemBuilder: (context) {
              return languages
                  .map((e) => Container(
                        alignment: Alignment.topCenter,
                        child: Text(
                          e[0],
                          style: TextStyle(
                              color: appTheme.sub1,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600),
                        ),
                      ))
                  .toList();
            },
            items: languages
                .map((e) => DropdownMenuItem(
                      child: Text(e[0],
                          style:
                              TextStyle(color: appTheme.sub1, fontSize: 13.sp)),
                      value: e[1],
                    ))
                .toList()),
      ),
    );
  }
}
