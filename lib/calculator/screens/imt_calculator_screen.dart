import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

/// Цвета
const Color kMintDark = Color(0xFF00B4AB);
const Color kBackground = Color(0xFFE7F7F7);

/// Единицы измерения
enum UnitSystem { metric, imperial }

/// Пол
enum Sex { male, female }

class BmiAdvancedCalculatorScreen extends StatefulWidget {
  const BmiAdvancedCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<BmiAdvancedCalculatorScreen> createState() =>
      _BmiAdvancedCalculatorScreenState();
}

class _BmiAdvancedCalculatorScreenState extends State<BmiAdvancedCalculatorScreen>
    with SingleTickerProviderStateMixin {
  UnitSystem _selectedUnit = UnitSystem.metric;
  Sex _selectedSex = Sex.male;

  double _weightSlider = 70.0;
  double _heightSlider = 170.0;
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController(text: '');

  double? _bmiValue;
  String _bmiCategory = '';
  String _bmiAdvice = '';
  bool _showResult = false;

  double? _normalWeightMin;
  double? _normalWeightMax;

  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Color?> _colorAnim;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _colorAnim = ColorTween(
      begin: Colors.white70,
      end: Colors.greenAccent.withOpacity(0.8),
    ).animate(_fadeAnim);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  double get _minWeight => (_selectedUnit == UnitSystem.metric) ? 30 : 66;
  double get _maxWeight => (_selectedUnit == UnitSystem.metric) ? 200 : 440;
  double get _minHeight => (_selectedUnit == UnitSystem.metric) ? 100 : 39;
  double get _maxHeight => (_selectedUnit == UnitSystem.metric) ? 250 : 98;

  /// Расчёт ИМТ и нормального веса
  void _calculateBMI() {
    double? w = double.tryParse(_weightCtrl.text);
    double? h = double.tryParse(_heightCtrl.text);
    w ??= _weightSlider;
    h ??= _heightSlider;

    double weightKg;
    double heightCm;
    if (_selectedUnit == UnitSystem.metric) {
      weightKg = w;
      heightCm = h;
    } else {
      weightKg = w * 0.45359237;
      heightCm = h * 2.54;
    }

    if (weightKg <= 0 || heightCm <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректные данные')),
      );
      return;
    }

    final double bmi = weightKg / pow((heightCm / 100), 2);

    String category;
    String advice;
    Color colorEnd = Colors.white70;

    if (bmi < 18.5) {
      category = 'Недостаточная масса';
      advice = 'Добавьте калорий, сбалансируйте рацион.';
      colorEnd = Colors.blueAccent.withOpacity(0.8);
    } else if (bmi < 25) {
      category = 'Норма';
      advice = 'Отлично, поддерживайте здоровый образ жизни!';
      colorEnd = Colors.greenAccent.withOpacity(0.8);
    } else if (bmi < 30) {
      category = 'Избыточная масса';
      advice = 'Увеличьте активность, пересмотрите питание.';
      colorEnd = Colors.orangeAccent.withOpacity(0.8);
    } else {
      category = 'Ожирение';
      advice = 'Желательна консультация специалиста.';
      colorEnd = Colors.redAccent.withOpacity(0.8);
    }

    final double heightM = heightCm / 100;
    _normalWeightMin = 18.5 * pow(heightM, 2);
    _normalWeightMax = 24.9 * pow(heightM, 2);

    setState(() {
      _bmiValue = bmi;
      _bmiCategory = category;
      _bmiAdvice = advice;
      _showResult = true;
    });

    _colorAnim = ColorTween(begin: Colors.white70, end: colorEnd).animate(_fadeAnim);
    _ctrl.forward(from: 0.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  double get _bmiClamped => _bmiValue == null ? 0 : (_bmiValue! > 40 ? 40 : _bmiValue!);

  /// Вместо build() используем composeScreen(), чтобы не было конфликта имени
  Widget composeScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kMintDark,
        title: const Text('Продвинутый ИМТ калькулятор'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kMintDark, kBackground],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildSexPicker(),
                const SizedBox(height: 12),
                _buildAgeInput(),
                const SizedBox(height: 12),
                _buildUnitSystemPicker(),
                const SizedBox(height: 20),
                _buildWeightControls(),
                const SizedBox(height: 20),
                _buildHeightControls(),
                const SizedBox(height: 30),
                _buildCalcButton(),
                const SizedBox(height: 30),
                if (_showResult && _bmiValue != null) ...[
                  _buildResultCircle(),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _colorAnim,
                    builder: (ctx, child) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: _colorAnim.value ?? Colors.white70,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              'Ваш ИМТ: ${_bmiValue!.toStringAsFixed(1)}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _bmiCategory,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _bmiAdvice,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_selectedUnit == UnitSystem.metric &&
                                _normalWeightMin != null &&
                                _normalWeightMax != null)
                              Text(
                                'Нормальный вес: ${_normalWeightMin!.toStringAsFixed(1)} - ${_normalWeightMax!.toStringAsFixed(1)} кг',
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Вместо build() – мы переопределяем build, но вызываем composeScreen
  @override
  Widget build(BuildContext context) {
    // Тут вызываем composeScreen, чтобы не было конфликта имени build
    return composeScreen(context);
  }

  /// Ниже – все остальные виджеты без изменений

  Widget _buildSexPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Radio<Sex>(
          value: Sex.male,
          groupValue: _selectedSex,
          onChanged: (val) => setState(() => _selectedSex = val ?? Sex.male),
        ),
        const Text('Муж.', style: TextStyle(color: Colors.white)),
        const SizedBox(width: 16),
        Radio<Sex>(
          value: Sex.female,
          groupValue: _selectedSex,
          onChanged: (val) => setState(() => _selectedSex = val ?? Sex.female),
        ),
        const Text('Жен.', style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildAgeInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _ageCtrl,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Возраст (лет)',
          hintStyle: TextStyle(color: Colors.black26),
        ),
      ),
    );
  }

  Widget _buildUnitSystemPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Система: ', style: TextStyle(color: Colors.white)),
        DropdownButton<UnitSystem>(
          value: _selectedUnit,
          dropdownColor: Colors.white,
          items: const [
            DropdownMenuItem(
              value: UnitSystem.metric,
              child: Text('Кг/см'),
            ),
            DropdownMenuItem(
              value: UnitSystem.imperial,
              child: Text('фунты/дюймы'),
            ),
          ],
          onChanged: (val) {
            setState(() {
              _selectedUnit = val ?? UnitSystem.metric;
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeightControls() {
    final double minW = _minWeight;
    final double maxW = _maxWeight;
    final String label =
    (_selectedUnit == UnitSystem.metric) ? 'Вес (кг)' : 'Вес (фунты)';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _weightCtrl,
              style: const TextStyle(fontSize: 16),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              ),
              onChanged: (val) {
                final parsed = double.tryParse(val);
                if (parsed != null) {
                  setState(() {
                    _weightSlider = parsed.clamp(minW, maxW);
                  });
                }
              },
            ),
          ),
          Slider(
            value: _weightSlider.clamp(minW, maxW),
            min: minW,
            max: maxW,
            divisions: (maxW - minW).round(),
            onChanged: (val) {
              setState(() {
                _weightSlider = val;
                _weightCtrl.text = val.toStringAsFixed(1);
              });
            },
          ),
          Text(
            _weightSlider.toStringAsFixed(1),
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightControls() {
    final double minH = _minHeight;
    final double maxH = _maxHeight;
    final String label =
    (_selectedUnit == UnitSystem.metric) ? 'Рост (см)' : 'Рост (дюймы)';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _heightCtrl,
              style: const TextStyle(fontSize: 16),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              ),
              onChanged: (val) {
                final parsed = double.tryParse(val);
                if (parsed != null) {
                  setState(() {
                    _heightSlider = parsed.clamp(minH, maxH);
                  });
                }
              },
            ),
          ),
          Slider(
            value: _heightSlider.clamp(minH, maxH),
            min: minH,
            max: maxH,
            divisions: (maxH - minH).round(),
            onChanged: (val) {
              setState(() {
                _heightSlider = val;
                _heightCtrl.text = val.toStringAsFixed(1);
              });
            },
          ),
          Text(
            _heightSlider.toStringAsFixed(1),
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcButton() {
    return InkWell(
      onTap: _calculateBMI,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          'Рассчитать',
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCircle() {
    final double clampBmi = (_bmiValue! > 40) ? 40 : _bmiValue!;
    return CustomPaint(
      size: const Size(220, 220),
      painter: _CircleResultPainter(value: clampBmi, maxValue: 40),
      child: SizedBox(
        width: 220,
        height: 220,
        child: Center(
          child: Text(
            '${_bmiValue!.toStringAsFixed(1)}',
            style: GoogleFonts.roboto(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Painter для кольца результата
class _CircleResultPainter extends CustomPainter {
  final double value;
  final double maxValue;

  _CircleResultPainter({required this.value, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Фон
    final paintBg = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;
    canvas.drawCircle(center, radius, paintBg);

    final double angle = 2 * pi * (value / maxValue);
    final paintArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Colors.pinkAccent, Colors.orangeAccent, Colors.yellowAccent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      angle,
      false,
      paintArc,
    );
  }

  @override
  bool shouldRepaint(_CircleResultPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.maxValue != maxValue;
  }
}
