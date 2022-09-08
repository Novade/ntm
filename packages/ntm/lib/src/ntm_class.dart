import 'package:ntm/src/describable.dart';

class NtmClass implements Describable {
  const NtmClass(this.name);

  final String name;

  @override
  String describe() {
    return name;
  }
}
