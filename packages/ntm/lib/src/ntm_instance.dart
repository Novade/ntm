import 'package:ntm/src/describable.dart';
import 'package:ntm/src/ntm_class.dart';

class NtmInstance implements Describable {
  const NtmInstance(this.ntmClass);

  final NtmClass ntmClass;

  @override
  String describe() {
    return '${ntmClass.name} instance';
  }
}
