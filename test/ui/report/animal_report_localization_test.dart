import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/ui/report/animal_report_localization.dart';

void main() {
  test('localizes display labels without changing form field ids', () async {
    final lao = await AppLocalizations.delegate.load(const Locale('lo'));
    final english = await AppLocalizations.delegate.load(const Locale('en'));
    final definition = <String, dynamic>{
      'sections': [
        {
          'questions': [
            {
              'label': 'Number of affected households',
              'fields': [
                {'id': 'num_household', 'name': 'num_household'}
              ],
            },
            {
              'label': 'Unrelated question',
              'fields': [
                {'id': 'other', 'name': 'other'}
              ],
            },
          ],
        },
      ],
    };

    final localized = localizeAnimalReportDefinition(
      'Animal Sick/Death',
      definition,
      lao,
    );
    final questions =
        (localized['sections'] as List).first['questions'] as List;
    expect(questions.first['label'], lao.animalReportAffectedHouseholds);
    expect(questions.first['fields'][0]['id'], 'num_household');
    expect(questions.last['label'], 'Unrelated question');
    expect((definition['sections'] as List).first['questions'][0]['label'],
        'Number of affected households');
    expect(localizeAnimalReportName('Animal Sick/Death', lao),
        lao.animalSickDeathReportName);
    expect(localizeAnimalReportName('Animal Sick/Death', english),
        'Animal Sick/Death');
    expect(
        localizeAnimalReportName('ສັດປ່ວຍ/ຕາຍ', english), 'Animal Sick/Death');
    expect(localizeAnimalReportName(' ລາຍງານສັດປ່ວຍ/ຕາຍ', english),
        'Animal Sick/Death');
    expect(
      localizeAnimalMetricLabel('Animal Sick/Death', 'num_sick', 'Sick', lao),
      lao.animalMetricSick,
    );
    expect(
        lao.animalMetricAffectedHouseholds, lao.animalReportAffectedHouseholds);
    expect(lao.animalMetricTotalAnimals, lao.animalReportTotalAnimals);
    expect(lao.animalMetricSick, lao.animalReportSick);
    expect(lao.animalMetricDead, lao.animalReportDead);
    expect(lao.animalMetricRecovered, lao.animalReportRecovered);
    expect(
      localizeAnimalMetricLabel('Other report', 'num_sick', 'Sick', lao),
      'Sick',
    );
    expect(
      localizeAnimalReportDefinition('Other report', definition, lao),
      same(definition),
    );

    final summary = localizeAnimalReportSummary(
      ' ລາຍງານສັດປ່ວຍ/ຕາຍ',
      {
        'animal_species': 'ງົວ',
        'num_sick': 2,
        'num_dead': 0,
        'num_total_animal': 20,
        'suspected_disease': 'ພະຍາດປາກເປືອຍລົງເລັບ',
        'animal_age_groups': {'value': 'ສັດແຮກເກີດ'},
        'animal_sex': {'value': 'ເພດຜູ້'},
        'num_household': 2,
      },
      DateTime(2026, 9, 28),
      lao,
    );
    expect(summary, contains('ຈຳນວນສັດປ່ວຍ: 2'));
    expect(summary, contains('ພະຍາດ: ພະຍາດປາກເປືອຍລົງເລັບ'));
    expect(summary, endsWith('28/09/2026'));
    expect(
      localizeAnimalReportSummary(
        'Animal Sick/Death',
        {'animal_species': 'Cattle'},
        null,
        english,
      ),
      isNull,
    );
  });
}
