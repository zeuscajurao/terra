import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/models/category.dart';
import 'package:terra/services/API/user_api.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/view_model/categories_vm.dart';

class SkillUpdateView extends StatefulWidget {
  const SkillUpdateView(
      {Key? key, required this.loadingCallback, required this.currentSkills})
      : super(key: key);
  final ValueChanged<bool> loadingCallback;
  final List<Category> currentSkills;
  @override
  State<SkillUpdateView> createState() => _SkillUpdateViewState();
}

class _SkillUpdateViewState extends State<SkillUpdateView> {
  final UserApi _api = UserApi();
  final CategoriesVm _vm = CategoriesVm.instance;
  late final List<int> _selected =
      widget.currentSkills.map((e) => e.id).toList();
  final AppColors _colors = AppColors.instance;
  void distinct() async {
    final List<Category> _r = List.from(_vm.value);
    final List<Category> _res =
        _r.where((element) => _selected.contains(element.id)).toList();
    loggedUser!.skills = _res;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return StreamBuilder<List<Category>>(
      stream: _vm.stream,
      builder: (_, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return Container();
        }
        final List<Category> _result = snapshot.data!;
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: size.height * .7,
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 0,
                        children: List.generate(
                          _result.length,
                          (index) => InputChip(
                            label: Text(
                              _result[index].name,
                              style: TextStyle(
                                color: _selected.contains(_result[index].id)
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            checkmarkColor: Colors.white,
                            selectedColor: _colors.bot,
                            showCheckmark: true,
                            onSelected: (bool s) {
                              print("PRINT : $s");
                              if (!_selected.contains(_result[index].id)) {
                                _selected.add(_result[index].id);
                              } else {
                                _selected.remove(_result[index].id);
                              }
                              if (mounted) setState(() {});
                            },
                            selected: _selected.contains(_result[index].id),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: size.width,
                child: MaterialButton(
                  height: 50,
                  color: _colors.bot,
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    if (_selected.isEmpty) {
                      Fluttertoast.showToast(
                          msg: "Must contain atleast 1 skill");
                      return;
                    }
                    widget.loadingCallback(true);
                    Navigator.of(context).pop(null);
                    await _api.updateSkills(_selected.join(',')).then((value) {
                      if (value) {
                        distinct();
                      }
                    }).whenComplete(() => widget.loadingCallback(false));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
