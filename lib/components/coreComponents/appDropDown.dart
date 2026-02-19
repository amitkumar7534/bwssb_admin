import 'package:bwssb/components/styles/textStyles.dart';
import 'package:flutter/material.dart';
import '../styles/appColors.dart';
import '../styles/appImages.dart';
import '../styles/decoration.dart';
import 'TextView.dart';

class AppDropDown<T> extends FormField<String>{
  AppDropDown.singleSelect({super.key,
    super.validator,
    required List<T> list, String? title,
    Function(MenuController)? onCreateController,
    required T? selectedValue,
    required Function(T) itemBuilder,
    required Function(T) singleValueBuilder,
    required Function(T)? onSingleChange,
    String? hint,
    Widget? textBox,
    String? error,
    TextStyle? style,
    bool isEnabled = true,
    bool? isFilled,
    Color? borderColor,
    double? radius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? menuMaxHeight,
    double? width,
    // bool isMultiDropDown = false,
    // List<T>? multiSelectedValue,
    // Function(T)? multiValueBuilder,
    // Function(List<T>)? onMultiChange,

  }) : super(
    builder: (FormFieldState<String> state) {
      return AppDropDownContent<T>.singleSelect(
        list: list,
        selectedValue: selectedValue,
        singleValueBuilder: singleValueBuilder,
        itemBuilder: itemBuilder,
        onSingleChange: onSingleChange,
        padding: padding,
        error: selectedValue != null ? null :
        (error ?? state.errorText),
        hint: hint,
        key: key,
        title: title,
        margin: margin,
        style: style,
        width: width,
        radius: radius,
        isEnabled: isEnabled,
        borderColor: borderColor,
        textBox: textBox,
        menuMaxHeight: menuMaxHeight,
        onCreateController: onCreateController,
        // onMultiChange: onMultiChange,
        // multiSelectedValue: multiSelectedValue,
        // multiValueBuilder: multiValueBuilder,
        // isFilled: isFilled,
        // isMultiDropDown: isMultiDropDown,
      );

    },
  );





  AppDropDown.multiSelect({
    super.key,
    super.validator,
    required List<T> list,
    required List<T> multiSelectedValue,
    required Function(T) multiValueBuilder,
    required Function(List<T>) onMultiChange,
    required Function(T) itemBuilder,
    String? title,
    Color? borderColor,
    double? radius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? menuMaxHeight,
    double? width,
    String? hint,
    Widget? textBox,
    Function(MenuController)? onCreateController,
    // T? selectedValue,
    // Function(T)? singleValueBuilder,
    // Function(T)? onSingleChange,
    // bool isMultiDropDown = true,
    String? error,
    TextStyle? style,
    bool isEnabled = true,
  }) : super(

    builder: (FormFieldState<String> state) {
      return AppDropDownContent<T>.multiSelect(
        // selectedValue: selectedValue,
        // singleValueBuilder: singleValueBuilder,
        // onSingleChange: onSingleChange,
        // isFilled: isFilled,
        // isMultiDropDown: isMultiDropDown,
        itemBuilder: itemBuilder,
        list: list,
        padding: padding,
        error: multiSelectedValue.isNotEmpty ? null :  (error ?? state.errorText),
        hint: hint,
        key: key,
        title: title,
        margin: margin,
        style: style,
        width: width,
        radius: radius,
        isEnabled: isEnabled,
        borderColor: borderColor,
        menuMaxHeight: menuMaxHeight,
        multiSelectedValue: multiSelectedValue,
        multiValueBuilder: multiValueBuilder,
        onCreateController: onCreateController,
        onMultiChange: onMultiChange,
        textBox: textBox,
      );

    },
  );

}













class AppDropDownContent<T> extends StatelessWidget {
  final List<T> list;
  final bool isFilled;
  final Color? borderColor;
  final double? radius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? menuMaxHeight;
  final double? width;
  final Function(MenuController)? onCreateController;

  final bool isMultiDropDown;
  final List<T>? multiSelectedValue;
  final T? selectedValue;
  final Function(T) itemBuilder;
  final String? title;
  final Function(T)? singleValueBuilder;
  final Function(T)? multiValueBuilder;
  final Function(T)? onSingleChange;
  final Function(List<T>)? onMultiChange;
  final String? hint;
  final Widget? textBox;
  final String? error;
  TextStyle? style;
  final bool isEnabled;

  AppDropDownContent.multiSelect({
    super.key,
    this.isMultiDropDown = true,
    this.title,
    required this.list,
    required this.multiSelectedValue,
    required this.multiValueBuilder,
    required this.itemBuilder,
    required this.onMultiChange,
    this.onSingleChange,
    this.error,
    this.selectedValue,
    this.singleValueBuilder,
    this.hint,
    this.isFilled = false,
    this.borderColor,
    this.radius,
    this.padding,
    this.menuMaxHeight,
    this.width,
    this.textBox,
    this.onCreateController,
    this.style,
    this.isEnabled = true, this.margin,
  });

  AppDropDownContent.singleSelect({
    this.isEnabled = true,
    super.key,
    this.title,
    this.isMultiDropDown = false,
    required this.list,
    required this.selectedValue,
    required this.singleValueBuilder,
    required this.itemBuilder,
    required this.onSingleChange,
    this.onMultiChange,
    this.multiValueBuilder,
    this.multiSelectedValue,
    this.hint,
    this.isFilled = false,
    this.borderColor,
    this.radius,
    this.padding,
    this.menuMaxHeight,
    this.width,
    this.error,
    this.textBox,
    this.onCreateController,
    this.style, this.margin,
  });

  @override
  Widget build(BuildContext context) {
    // final borderStyle = AppDecoration.bDecorationGreyR(
    //     borderColor: borderColor, radius: radius ?? 10);
    String hintValue = hint != null && hint!.trim().isNotEmpty ? hint! : '';
    String? value = generateValue();
    MenuController controller = MenuController();
    return _dropDownWidget(
        title: title,
        margin: margin,
        isEnabled: isEnabled,
        controller: controller,
        style: style,
        width: width,
        error: error,
        hintValue: hintValue,
        value: value,
        // decoration: BoxDecoration(color: AppColors.bkColor),
        //  decoration: borderStyle,
        textBox: textBox,
        getController: (ctrl) =>
        onCreateController != null ? onCreateController!(ctrl) : null,
        menuList: isEnabled
            ? [
          ...list.asMap().entries.map((e) => InkWell(
              onTap: () {
                if (isMultiDropDown) {
                  List<T> list = multiSelectedValue ?? [];
                  if (multiSelectedValue!.contains(e.value)) {
                    list.remove(e.value);
                  } else {
                    list.add(e.value);
                  }
                  onMultiChange!(list);
                } else {
                  controller.close();
                  onSingleChange!(e.value);
                }
              },
              child: Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                      color: isMultiDropDown &&
                          multiSelectedValue!.contains(e.value)
                          ? AppColors.grey.withOpacity(0.2)
                          : AppColors.white,
                      border: const Border.symmetric(
                          horizontal: BorderSide(
                              color: AppColors.grey, width: 0.5))),
                  padding: const EdgeInsets.all(15),
                  child: TextView(
                    text: itemBuilder(e.value) ?? '',
                    style: 13.txtRegularBlack,
                  ))))
        ]
            : []);
  }

  String? generateValue() {
    if (isMultiDropDown) {
      if (multiSelectedValue != null && multiSelectedValue!.isNotEmpty) {
        List<String> finalValue = [];
        for (var item in multiSelectedValue!) {
          String value = multiValueBuilder!(item);
          finalValue.add(value);
        }
        return finalValue.map((element) => element.toString()).join(', ');
      } else {
        return null;
      }
    } else {
      if (selectedValue != null) {
        String value = singleValueBuilder!(selectedValue!);
        return value;
      } else {
        return null;
      }
    }
  }
}




















Widget _dropDownWidget(
    {required MenuController controller,
      required double? width,
      required List<Widget> menuList,
      required String? value,
      required String hintValue,
      required String? title,
      required bool isEnabled,
      TextStyle? style,
      String? error,
      EdgeInsets? margin,
      // required BoxDecoration decoration,
      Widget? textBox,
      required Function(MenuController) getController}) {
  double getWidth(BoxConstraints boxConstraints) {
    if (boxConstraints.maxWidth == double.infinity ||
        boxConstraints.maxWidth == double.maxFinite) {
      return 250;
    }
    return boxConstraints.maxWidth;
  }

  return Padding(
    padding: margin ?? EdgeInsets.zero,
    child: LayoutBuilder(builder: (context, boxConstraints) {
      double modalWidth = width ?? getWidth(boxConstraints);
      double minHeight = isEnabled ? 10 : 0;
      double maxHeight = isEnabled ? 400 : 0;
      // double minHeight = isEnabled ?0 : 10;
      // double maxHeight = isEnabled ?0 :400;
      return MenuAnchor(
        controller: controller,
        crossAxisUnconstrained: false,
        clipBehavior: Clip.hardEdge,
        consumeOutsideTap: true,
        style: MenuStyle(
            backgroundColor: WidgetStateProperty.all(AppColors.white),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            )),
            maximumSize: WidgetStateProperty.resolveWith((states) {
              return Size(modalWidth, maxHeight);
            }),
            minimumSize: WidgetStateProperty.resolveWith((states) {
              return Size(modalWidth, minHeight);
            }),
            padding: WidgetStateProperty.resolveWith((states) {
              return EdgeInsets.zero;
            }),
            side: WidgetStateProperty.all(
                const BorderSide(color: AppColors.white))),
        builder: (context, controller, _) {
          getController(controller);

          return SizedBox(
            width: modalWidth,
            child: textBox ??
                InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  onTap: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        // decoration: decoration,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: AppColors.white,
                          border: Border.all(color: Colors.grey.withOpacity(0.5)), // Grey border
                        ),

                        width: modalWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                                visible: title != null,
                                child: TextView(text: title ?? '', style: 14.txtRegularBlack,)),
                            Row(
                              children: [
                                Expanded(
                             child: TextView(
                               text: value ?? hintValue,
                               style: value == null
                                   ? (style ?? TextStyle(
                                 fontSize: 16,
                                 color: Colors.grey.shade600,
                                 fontWeight: FontWeight.normal,
                               ))
                                   : (style ?? 14.txtRegularBlack),
                             ),

                                ),
                                Icon(Icons.keyboard_arrow_down_sharp,size: 30,color: AppColors.grey,)
                                // Container(
                                //   color: Colors.purple,
                                //   child: Icon(
                                //     Icons.keyboard_arrow_down_outlined,
                                //     color: AppColors.greyText.withOpacity(0.7),
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      errorText(error)
                    ],
                  ),
                ),
          );
        },
        menuChildren: menuList,
      );
    }),
  );
}

Widget errorText(String? value) {
  return Visibility(
      visible: value != null && value.trim().isNotEmpty,
      child: TextView(
        text: value ?? '',
        // style: 12.txtRegularError,
        style: 12.txtRegularWhite,
      ));
}
