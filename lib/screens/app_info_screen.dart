import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../utils/app_colors.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  // Текст с использованием Markdown-разметки
  static const String _markdownText = '''
**Добро пожаловать в "Карманный доктор"** — ваш персональный помощник в мире здоровья и благополучия!

"Карманный доктор" создан для того, чтобы сделать заботу о вашем здоровье максимально простой, эффективной и современной. Наше приложение объединяет множество полезных функций, которые помогут вам контролировать прием лекарств, следить за важными показателями здоровья и получать профессиональные рекомендации в режиме реального времени.

Основные возможности приложения:
Умный календарь: Планируйте прием препаратов и получайте своевременные напоминания, чтобы ни одна доза не была пропущена.

Мониторинг здоровья: Отслеживайте артериальное давление, частоту сердечных сокращений и другие ключевые параметры для оперативной диагностики и контроля состояния.

Расшифровка анализов: Получайте подробные рекомендации и советы на основе результатов ваших анализов.

Отслеживание развития ребенка: Следите за ростом и весом вашего ребенка от рождения до 18 лет. В специальном разделе вы найдете не только таблицы с динамикой показателей, но и подробные описания этапов развития, а также рекомендации по питанию, основанные на международных стандартах.

Раздел для мам: Специально для молодых и будущих родителей – советы, лайфхаки и рекомендации по уходу за малышом, помогающие сделать этот важный период более комфортным.

Персонализация и адаптивный дизайн: Удобный интерфейс, оптимизированный для любых устройств, позволяет легко пользоваться приложением в повседневной жизни.

Мы постоянно совершенствуем "Карманного доктора", чтобы он оставался вашим надежным союзником в мире здоровья. С нашим приложением вы всегда будете в курсе изменений, а профессиональные рекомендации помогут поддерживать ваше благополучие на самом высоком уровне.

Откройте для себя новый уровень заботы о здоровье — потому что ваше самочувствие заслуживает самого лучшего!
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('О приложении'),
        backgroundColor: AppColors.kMintDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Блок с общими сведениями
            Text(
              'Название: Карманный доктор',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Версия: 1.0.0',
              style: GoogleFonts.lato(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Разработчик: Ваша команда / компания',
              style: GoogleFonts.lato(fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Заголовок "Описание"
            Text(
              'Описание:',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Markdown-текст
            MarkdownBody(
              data: _markdownText,
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.lato(fontSize: 16),
                h2: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                strong: GoogleFonts.lato(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            // Контакты
            Text(
              'Контакты:',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: dmitrymozol.dev@gmail.com\n'
                  'Сайт: https://\n',
              style: GoogleFonts.lato(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
