import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../utils/app_colors.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  // Текст с использованием Markdown-разметки
  static const String _markdownText = '''
**Добро пожаловать в "Карманный доктор"** — ваш персональный помощник в мире здоровья и благополучия!

Это приложение создано, чтобы стать вашим незаменимым союзником в повседневном контроле над состоянием здоровья. 
От своевременных напоминаний о приёме лекарств до мониторинга жизненно важных показателей — "Карманный доктор" объединяет в себе все необходимые инструменты для заботы о вашем самочувствии.

## Особенности приложения:
- **Умный календарь** – планируйте приём препаратов и получайте уведомления, чтобы ни одна доза не была пропущена.
- **Мониторинг здоровья** – отслеживайте артериальное давление, ЧСС и другие ключевые показатели, чтобы всегда знать, как вы себя чувствуете.
- **Расшифровка анализов** – получайте понятные рекомендации и советы на основе результатов ваших исследований.
- **Для мам** – специальный раздел с советами и рекомендациями для молодых и будущих родителей.
- **Калькулятор лекарств** – рассчитывайте дозировку в зависимости от возраста и веса для максимальной безопасности.

Мы стремимся сделать заботу о здоровье максимально простой, удобной и эффективной. 
С "Карманным доктором" все важные моменты под контролем, а вы можете быть уверены в том, что ваше здоровье находится в надёжных руках.

Откройте для себя новый уровень личной заботы о здоровье — потому что ваше самочувствие заслуживает самого лучшего!
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
              'Email: mozol.dima97@mail.ru\n'
                  'Сайт: https://porhub.com\n',
              style: GoogleFonts.lato(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
