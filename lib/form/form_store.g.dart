// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$FormStore on _FormStore, Store {
  Computed<Section>? _$currentSectionComputed;

  @override
  Section get currentSection => (_$currentSectionComputed ??= Computed<Section>(
          () => super.currentSection,
          name: '_FormStore.currentSection'))
      .value;
  Computed<bool>? _$couldGoToPreviousSectionComputed;

  @override
  bool get couldGoToPreviousSection => (_$couldGoToPreviousSectionComputed ??=
          Computed<bool>(() => super.couldGoToPreviousSection,
              name: '_FormStore.couldGoToPreviousSection'))
      .value;
  Computed<bool>? _$couldGoToNextSectionComputed;

  @override
  bool get couldGoToNextSection => (_$couldGoToNextSectionComputed ??=
          Computed<bool>(() => super.couldGoToNextSection,
              name: '_FormStore.couldGoToNextSection'))
      .value;
  Computed<String>? _$currentSectionHeaderComputed;

  @override
  String get currentSectionHeader => (_$currentSectionHeaderComputed ??=
          Computed<String>(() => super.currentSectionHeader,
              name: '_FormStore.currentSectionHeader'))
      .value;

  final _$currentSectionIdxAtom = Atom(name: '_FormStore.currentSectionIdx');

  @override
  int get currentSectionIdx {
    _$currentSectionIdxAtom.reportRead();
    return super.currentSectionIdx;
  }

  @override
  set currentSectionIdx(int value) {
    _$currentSectionIdxAtom.reportWrite(value, super.currentSectionIdx, () {
      super.currentSectionIdx = value;
    });
  }

  final _$submitAsyncAction = AsyncAction('_FormStore.submit');

  @override
  Future<bool> submit() {
    return _$submitAsyncAction.run(() => super.submit());
  }

  final _$_FormStoreActionController = ActionController(name: '_FormStore');

  @override
  void next() {
    final _$actionInfo =
        _$_FormStoreActionController.startAction(name: '_FormStore.next');
    try {
      return super.next();
    } finally {
      _$_FormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void previous() {
    final _$actionInfo =
        _$_FormStoreActionController.startAction(name: '_FormStore.previous');
    try {
      return super.previous();
    } finally {
      _$_FormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  bool validate() {
    final _$actionInfo =
        _$_FormStoreActionController.startAction(name: '_FormStore.validate');
    try {
      return super.validate();
    } finally {
      _$_FormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentSectionIdx: ${currentSectionIdx},
currentSection: ${currentSection},
couldGoToPreviousSection: ${couldGoToPreviousSection},
couldGoToNextSection: ${couldGoToNextSection},
currentSectionHeader: ${currentSectionHeader}
    ''';
  }
}
