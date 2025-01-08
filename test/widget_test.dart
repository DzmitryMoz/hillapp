// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hillapp/main.dart';

void main() {
  testWidgets('Login Screen Test', (WidgetTester tester) async {
    await tester.pumpWidget(const HillApp());

    // Проверяем, что экран входа отображается
    expect(find.text('Вход'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Пароль'), findsOneWidget);
    expect(find.text('Войти'), findsOneWidget);
    expect(find.text('Зарегистрироваться'), findsOneWidget);

    // Вводим email и пароль
    await tester.enterText(find.byType(TextFormField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    // Нажимаем кнопку входа
    await tester.tap(find.text('Войти'));
    await tester.pump();

    // Ждём перехода
    await tester.pumpAndSettle();

    // Проверяем, что отображается домашний экран
    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('Полноценный календарь'), findsOneWidget);
    expect(find.text('Контроль АД'), findsOneWidget);
    expect(find.text('Расшифровка анализов'), findsOneWidget);
    expect(find.text('Калькулятор лекарств'), findsOneWidget);
  });

  testWidgets('Register Screen Test', (WidgetTester tester) async {
    await tester.pumpWidget(const HillApp());

    // Переходим на экран регистрации
    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();

    // Проверяем, что экран регистрации отображается
    expect(find.text('Регистрация'), findsOneWidget);
    expect(find.text('Имя'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Пароль'), findsOneWidget);
    expect(find.text('Зарегистрироваться'), findsOneWidget);
    expect(find.text('Уже есть аккаунт? Войдите'), findsOneWidget);

    // Вводим данные
    await tester.enterText(find.byType(TextFormField).at(0), 'Имя пользователя');
    await tester.enterText(find.byType(TextFormField).at(1), 'user@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');

    // Нажимаем кнопку регистрации
    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pump();

    // Ждём перехода
    await tester.pumpAndSettle();

    // Проверяем, что отображается домашний экран
    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('Полноценный календарь'), findsOneWidget);
    expect(find.text('Контроль АД'), findsOneWidget);
    expect(find.text('Расшифровка анализов'), findsOneWidget);
    expect(find.text('Калькулятор лекарств'), findsOneWidget);
  });

  testWidgets('Profile Screen Theme Toggle Test', (WidgetTester tester) async {
    await tester.pumpWidget(const HillApp());

    // Вход в приложение
    await tester.enterText(find.byType(TextFormField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    // Переходим в профиль
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    // Проверяем наличие переключателя темы
    expect(find.text('Тёмная тема'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsNWidgets(2));

    // Переключаем тему
    await tester.tap(find.byType(SwitchListTile).at(1));
    await tester.pumpAndSettle();

    // Проверяем, что тема изменилась (тестируем наличие элементов, характерных для тёмной темы)
    // Например, цвет AppBar
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, equals(Colors.grey[900]));
  });
}
