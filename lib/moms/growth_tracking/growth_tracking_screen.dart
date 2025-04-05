import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

/// Главный виджет приложения
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Рост и вес ребенка',
      theme: ThemeData(
        primaryColor: AppColors.kMintDark,
        scaffoldBackgroundColor: AppColors.kBackground,
      ),
      home: const GrowthTrackingScreen(),
    );
  }
}

/// Класс с цветовыми константами приложения
class AppColors {
  static const kMintLight = Color(0xFF00E5D1); // Светлый оттенок
  static const kMintDark = Color(0xFF00B4AB); // Базовый цвет
  static const kBackground = Color(0xFFE3FDFD);
}

/// Тип показателя: Рост или Вес
enum MeasurementType { height, weight }

/// Модель данных для одного возрастного промежутка
class ChildGrowthData {
  final String age;    // Например: "1 месяц", "2 месяца", "1 год", "2 года", …, "18 лет"
  final double height; // Рост в сантиметрах
  final double weight; // Вес в килограммах
  final String description; // Этап развития (для режима "Рост")
  final String nutritionRecommendations; // Рекомендации по питанию (для режима "Вес")

  ChildGrowthData({
    required this.age,
    required this.height,
    required this.weight,
    required this.description,
    required this.nutritionRecommendations,
  });
}

/// Экран для отслеживания роста и веса ребенка
class GrowthTrackingScreen extends StatefulWidget {
  const GrowthTrackingScreen({Key? key}) : super(key: key);

  @override
  State<GrowthTrackingScreen> createState() => _GrowthTrackingScreenState();
}

class _GrowthTrackingScreenState extends State<GrowthTrackingScreen> {
  /// Текущее выбранное измерение: Рост или Вес
  MeasurementType _selectedMeasurement = MeasurementType.height;

  /// Список данных с возрастными промежутками (от 1 месяца до 18 лет)
  final List<ChildGrowthData> childGrowthData = [
    // Младенчество (месяцы)
    ChildGrowthData(
      age: '1 месяц',
      height: 54.0,
      weight: 4.5,
      description:
      'В 1 месяц ребенок начинает адаптироваться к окружающему миру, фиксирует взгляд на родителях, начинает различать звуки и образы.',
      nutritionRecommendations:
      'Рекомендуется исключительно грудное вскармливание или адаптированная смесь по рекомендации врача.',
    ),
    ChildGrowthData(
      age: '2 месяца',
      height: 57.0,
      weight: 5.0,
      description:
      'Во 2 месяца развивается зрение и слух, появляется первая улыбка, ребенок реагирует на знакомые голоса.',
      nutritionRecommendations:
      'Продолжайте грудное вскармливание или смесь, следите за частотой кормлений – обычно 6–8 раз в сутки.',
    ),
    ChildGrowthData(
      age: '3 месяца',
      height: 58.0,
      weight: 6.4,
      description:
      'В 3 месяца усиливается координация движений, ребенок начинает наблюдать за своими руками и лицом.',
      nutritionRecommendations:
      'Кормления должны быть регулярными; обращайте внимание на сигналы сытости ребенка.',
    ),
    ChildGrowthData(
      age: '4 месяца',
      height: 62.0,
      weight: 7.0,
      description:
      'В 4 месяца ребенок активно улыбается, начинает переворачиваться, изучая окружающий мир.',
      nutritionRecommendations:
      'Грудное вскармливание или смесь остаются основным источником питания; можно обсудить начало прикорма с врачом.',
    ),
    ChildGrowthData(
      age: '5 месяцев',
      height: 64.0,
      weight: 7.5,
      description:
      'В 5 месяцев развивается моторика: ребенок может хватать игрушки, проявляет интерес к ярким объектам.',
      nutritionRecommendations:
      'Питание грудным молоком/смесью, при необходимости – консультация педиатра по поводу введения прикорма.',
    ),
    ChildGrowthData(
      age: '6 месяцев',
      height: 65.0,
      weight: 7.8,
      description:
      'В 6 месяцев ребенок начинает переворачиваться, сидеть с поддержкой и изучать игрушки, улучшая координацию движений.',
      nutritionRecommendations:
      'В этом возрасте можно начинать вводить прикорм: овощные и фруктовые пюре, каши – постепенно, согласно рекомендациям специалиста.',
    ),
    // Раннее детство и школьный возраст
    ChildGrowthData(
      age: '1 год',
      height: 75.0,
      weight: 9.5,
      description:
      'В 12 месяцев ребенок делает первые шаги, начинает активно исследовать окружающее пространство самостоятельно.',
      nutritionRecommendations:
      'Переход на смешанное питание: грудное молоко/смесь плюс небольшие порции твердой пищи, сбалансированной по белкам, жирам и углеводам.',
    ),
    ChildGrowthData(
      age: '2 года',
      height: 87.0,
      weight: 12.0,
      description:
      'В 2 года ребенок начинает уверенно ходить, развивается речь, появляется интерес к самостоятельным действиям.',
      nutritionRecommendations:
      'Разнообразное питание с упором на овощи, фрукты, молочные продукты и умеренное количество белка; избегайте избыточного сахара.',
    ),
    ChildGrowthData(
      age: '3 года',
      height: 95.0,
      weight: 14.0,
      description:
      'В 3 года расширяется словарный запас, ребенок начинает играть с другими детьми и проявлять самостоятельность.',
      nutritionRecommendations:
      'Сбалансированный рацион с малыми порциями и регулярными приемами пищи, уделяя внимание качеству продуктов.',
    ),
    ChildGrowthData(
      age: '4 года',
      height: 102.0,
      weight: 16.0,
      description:
      'В 4 года ребенок начинает самостоятельно одеваться, развивает мелкую моторику и творческие способности.',
      nutritionRecommendations:
      'Поддерживайте разнообразие в рационе, включая свежие овощи, фрукты, цельнозерновые продукты и белковые источники.',
    ),
    ChildGrowthData(
      age: '5 лет',
      height: 108.0,
      weight: 18.0,
      description:
      'В 5 лет ребенок готовится к школе, развивается логическое мышление, память и коммуникативные навыки.',
      nutritionRecommendations:
      'Важно обеспечить полноценный завтрак, регулярные приемы пищи и ограничить сладкие закуски.',
    ),
    ChildGrowthData(
      age: '6 лет',
      height: 115.0,
      weight: 20.0,
      description:
      'В 6 лет ребенок начинает читать и писать, активно общается с сверстниками и осваивает базовые навыки самостоятельности.',
      nutritionRecommendations:
      'Обратите внимание на полноценное питание с достаточным количеством белков, витаминов и минералов для поддержания активности.',
    ),
    ChildGrowthData(
      age: '7 лет',
      height: 121.0,
      weight: 22.0,
      description:
      'В 7 лет ребенок укрепляет социальные навыки, начинает понимать правила поведения и сотрудничать в группе.',
      nutritionRecommendations:
      'Сбалансированный рацион с включением здоровых перекусов, таких как орехи, йогурт или свежие фрукты.',
    ),
    ChildGrowthData(
      age: '8 лет',
      height: 127.0,
      weight: 24.0,
      description:
      'В 8 лет ребенок активно занимается спортом или творческими занятиями, развивая координацию и физическую выносливость.',
      nutritionRecommendations:
      'Следите за достаточным потреблением кальция и витамина D для поддержки костной системы, а также за общим сбалансированным питанием.',
    ),
    ChildGrowthData(
      age: '9 лет',
      height: 133.0,
      weight: 26.0,
      description:
      'В 9 лет ребенок расширяет кругозор, начинает самостоятельно выполнять задания и решать небольшие проблемы.',
      nutritionRecommendations:
      'Регулярные приемы пищи с умеренными порциями, достаточным количеством овощей, фруктов и цельнозерновых продуктов.',
    ),
    ChildGrowthData(
      age: '10 лет',
      height: 138.0,
      weight: 28.0,
      description:
      'В 10 лет ребенок демонстрирует повышенную самостоятельность, учится брать ответственность за учебные задания.',
      nutritionRecommendations:
      'Сбалансированный рацион с достаточным количеством белков, углеводов и жиров для поддержания энергии в течение дня.',
    ),
    ChildGrowthData(
      age: '11 лет',
      height: 143.0,
      weight: 32.0,
      description:
      'В 11 лет начинается активное развитие физических способностей, ребенок интересуется спортом и командными играми.',
      nutritionRecommendations:
      'Рацион с включением сложных углеводов, нежирного мяса, свежих овощей и фруктов для поддержки роста и активности.',
    ),
    ChildGrowthData(
      age: '12 лет',
      height: 148.0,
      weight: 36.0,
      description:
      'В 12 лет ребенок переживает переходный период с эмоциональными и физическими изменениями, интересуется самоопределением.',
      nutritionRecommendations:
      'Сбалансированное питание, включающее разнообразные группы продуктов, поможет справиться с гормональными изменениями и поддерживать энергию.',
    ),
    ChildGrowthData(
      age: '13 лет',
      height: 157.0,
      weight: 40.0,
      description:
      'В 13 лет начинается формирование индивидуальности, ребенок проявляет первые признаки самостоятельного мышления.',
      nutritionRecommendations:
      'Увеличьте потребление белка и овощей, а также обеспечьте регулярный прием пищи для поддержки интенсивного роста.',
    ),
    ChildGrowthData(
      age: '14 лет',
      height: 163.0,
      weight: 45.0,
      description:
      'В 14 лет подросток активно развивается, появляются новые увлечения и меняется отношение к окружающему миру.',
      nutritionRecommendations:
      'Сбалансированный рацион с включением сложных углеводов, белков и полезных жиров будет способствовать здоровому развитию.',
    ),
    ChildGrowthData(
      age: '15 лет',
      height: 168.0,
      weight: 50.0,
      description:
      'В 15 лет подросток продолжает формировать свою личность, сталкивается с новыми социальными вызовами и ответственностью.',
      nutritionRecommendations:
      'Обеспечьте достаточное количество энергии и питательных веществ, особенно во время активных физических нагрузок и учебы.',
    ),
    ChildGrowthData(
      age: '16 лет',
      height: 172.0,
      weight: 55.0,
      description:
      'В 16 лет подросток становится более самостоятельным, развивается критическое мышление и уверенность в себе.',
      nutritionRecommendations:
      'Включайте в рацион продукты, богатые антиоксидантами, и следите за балансом белков, жиров и углеводов.',
    ),
    ChildGrowthData(
      age: '17 лет',
      height: 175.0,
      weight: 60.0,
      description:
      'В 17 лет подросток готовится ко взрослой жизни, определяются жизненные приоритеты и цели, формируется мировоззрение.',
      nutritionRecommendations:
      'Разнообразное питание с упором на свежие овощи, фрукты, цельнозерновые продукты и качественный белок станет хорошей базой для активного развития.',
    ),
    ChildGrowthData(
      age: '18 лет',
      height: 177.0,
      weight: 65.0,
      description:
      'В 18 лет молодой человек завершает этап подросткового развития и готовится к самостоятельной взрослой жизни.',
      nutritionRecommendations:
      'Полноценное, сбалансированное питание, соблюдение режима дня и активный образ жизни помогут плавно перейти во взрослую жизнь.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(builder: (context, constraints) {
        double horizontalMargin = constraints.maxWidth * 0.04;
        double columnSpacing = constraints.maxWidth * 0.08;
        if (horizontalMargin < 16.0) horizontalMargin = 16.0;
        if (columnSpacing < 40.0) columnSpacing = 40.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Рост и вес ребенка'),
            backgroundColor: AppColors.kMintDark,
          ),
          body: Column(
            children: [
              const SizedBox(height: 16.0),
              ToggleButtons(
                isSelected: [
                  _selectedMeasurement == MeasurementType.height,
                  _selectedMeasurement == MeasurementType.weight,
                ],
                onPressed: (int index) {
                  setState(() {
                    _selectedMeasurement =
                    (index == 0) ? MeasurementType.height : MeasurementType.weight;
                  });
                },
                borderRadius: BorderRadius.circular(8.0),
                selectedColor: Colors.white,
                fillColor: AppColors.kMintDark,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Рост'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Вес'),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(AppColors.kMintLight),
                        horizontalMargin: horizontalMargin,
                        columnSpacing: columnSpacing,
                        headingRowHeight: 48.0,
                        dataRowHeight: 48.0,
                        columns: _buildColumns(),
                        rows: childGrowthData
                            .map((data) => _buildDataRow(data, context))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(
        label: Text(
          'Возраст',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      DataColumn(
        label: Text(
          _selectedMeasurement == MeasurementType.height ? 'Рост (см)' : 'Вес (кг)',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ];
  }

  DataRow _buildDataRow(ChildGrowthData data, BuildContext context) {
    final measurementValue =
    _selectedMeasurement == MeasurementType.height ? data.height : data.weight;

    return DataRow(
      cells: [
        DataCell(
          Text(
            data.age,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.kMintDark),
          ),
          onTap: () => _showDetails(context, data),
        ),
        DataCell(
          Text(
            measurementValue.toStringAsFixed(1),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.kMintDark),
          ),
        ),
      ],
    );
  }

  void _showDetails(BuildContext context, ChildGrowthData data) {
    // В зависимости от выбранного режима показываем описание развития или рекомендации по питанию
    final String title = data.age;
    final String content = _selectedMeasurement == MeasurementType.height
        ? data.description
        : data.nutritionRecommendations;
    final String contentTitle = _selectedMeasurement == MeasurementType.height
        ? 'Этап развития'
        : 'Рекомендации по питанию';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.kBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kMintDark,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  contentTitle,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.kMintDark,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  content,
                  style: const TextStyle(fontSize: 16.0, color: AppColors.kMintDark),
                ),
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kMintDark,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Закрыть'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
