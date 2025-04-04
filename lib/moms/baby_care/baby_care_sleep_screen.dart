import 'package:flutter/material.dart';
import 'info_screen.dart';

class BabyCareSleepScreen extends StatelessWidget {
  const BabyCareSleepScreen({Key? key}) : super(key: key);

  final String sleepRegimenContent = '''
# **Режим сна ребёнка**

Сон играет **ключевую роль в развитии малыша**, помогая ему **восстанавливать силы, расти и укреплять нервную систему**. Важно **соблюдать режим сна**, чтобы ребёнок чувствовал себя хорошо и спокойно.

---

## **📌 1. Количество сна по возрасту**
Сон новорождённого **отличается от сна взрослых** – он состоит из **коротких циклов**, и малыш часто просыпается. С возрастом продолжительность сна уменьшается, а его структура становится похожей на взрослую.

### **🔹 Примерные нормы сна по возрасту**
✔ **0-3 месяца** – 16-18 часов в сутки, дневной сон **3-5 раз**.  
✔ **3-6 месяцев** – 14-16 часов в сутки, дневной сон **3-4 раза**.  
✔ **6-12 месяцев** – 12-14 часов, дневной сон **2-3 раза**.  
✔ **1-2 года** – 11-13 часов, дневной сон **1-2 раза**.  
✔ **2-3 года** – 10-12 часов, дневной сон **1 раз**.  
✔ **3-5 лет** – 10-11 часов, дневной сон постепенно исчезает.  

🚨 **Важно!**  
✔ Каждый ребёнок индивидуален – **некоторым малышам требуется больше или меньше сна**.  
✔ Недостаток сна может вызывать **капризы, беспокойство, ухудшение концентрации**.  
✔ Важно **обращать внимание на сигналы усталости** (зевота, потирание глаз, снижение активности).  

---

## **🌙 2. Организация ночного сна**
📌 **Как правильно укладывать ребёнка на ночь:**  
✔ Соблюдайте **режим сна** – ложитесь в одно и то же время.  
✔ Создайте **успокаивающий ритуал** перед сном (купание, массаж, чтение сказки).  
✔ Температура в комнате **18-22°C**, влажность **40-60%**.  
✔ Кровать должна быть **жёсткой, без лишних подушек и игрушек**.  
✔ Избегайте **яркого света** и экранов перед сном.  
✔ Не давайте **сладкое и активные игры за 2 часа до сна**.  

---

## **🌞 3. Организация дневного сна**
✔ Дневной сон **помогает малышу восстанавливаться и не переутомляться**.  
✔ Детям **до 3 лет** важно **спать днём хотя бы 1 раз**.  
✔ Дневной сон должен проходить в **проветренной комнате, в тишине**.  
✔ Не перекладывайте ребёнка в кровать **сразу после активных игр** – дайте ему успокоиться.  

🚨 **Как понять, что ребёнок готов к дневному сну?**  
✔ Начинает **зевать и тереть глазки**.  
✔ Становится **капризным и менее активным**.  
✔ Теряет интерес к игрушкам и окружающему миру.  

---
''';

  final String sleepSafetyContent = '''
# **🛏️ Безопасность во время сна**

**Безопасность сна – это один из главных аспектов, о которых должны заботиться родители.** Она включает **правильное положение ребёнка, выбор постельных принадлежностей и соблюдение температурного режима**.

---

## **📌 1. Как правильно укладывать ребёнка?**
✔ **Ребёнок должен спать на спине** – это **самая безопасная поза**.  
✔ Голова должна находиться **без наклона** – не используйте подушки до 1 года.  
✔ Матрас должен быть **жёстким**, без прогибов.  
✔ Одеяло не должно **перекрывать лицо малыша** – используйте **конверт или спальный мешок**.  
✔ Малыш должен **спать в отдельной кроватке** или в кроватке, приставленной к родительской.  

🚨 **Опасные позы для сна**  
🚫 На животе – увеличивается риск удушья.  
🚫 На боку – малыш может перевернуться на живот.  

---

## **🛏️ 2. Выбор матраса и постельных принадлежностей**
✔ **Матрас должен быть твёрдым и ровным** – без эффекта «памяти».  
✔ Чехол должен быть **дышащим и съёмным**.  
✔ **Подушки и мягкие бортики в кроватке запрещены** до 1 года – они могут стать причиной удушья.  
✔ Одеяло должно быть **лёгким**, лучше использовать **спальный мешок**.  
✔ Простыня должна быть **на резинке**, чтобы не сбиваться.  

🚨 **Чего нельзя класть в кроватку?**  
🚫 Плюшевые игрушки.  
🚫 Подушки и толстые одеяла.  
🚫 Сетчатые бортики – они могут стать причиной удушья.  

---
''';

  final String sleepEnvironmentContent = '''
# **🌡️ Создание комфортной обстановки для сна**

Спокойный и комфортный сон зависит не только от режима, но и от **условий в комнате**. Оптимальный климат помогает малышу **быстрее засыпать и крепко спать**.

---

## **📌 1. Температура и влажность воздуха**
✔ **Температура в комнате должна быть 18-22°C**.  
✔ **Влажность – 40-60%** (используйте увлажнитель воздуха).  
✔ **Проветривайте комнату перед сном** – свежий воздух помогает лучше заснуть.  
✔ Избегайте **перегрева** – ребёнок не должен потеть во время сна.  

🚨 **Что делать, если в комнате сухой воздух?**  
✔ Установите **увлажнитель воздуха**.  
✔ Развесьте **мокрые полотенца** на батареи.  
✔ Поставьте **миску с водой** у кроватки.  

---

## **🌙 2. Освещение во время сна**
✔ Ночью должен быть **полный мрак** – гормон сна (мелатонин) вырабатывается в темноте.  
✔ Можно использовать **ночник с тёплым светом**.  
✔ Дневной сон должен проходить **в затемнённой комнате**.  

🚨 **Чего нельзя делать?**  
🚫 Оставлять включённый телевизор.  
🚫 Использовать **яркий белый свет** перед сном.  

---

## **🔇 3. Уровень шума**
✔ **Тишина – лучший друг хорошего сна**.  
✔ Если малыш **плохо спит в тишине**, используйте **белый шум** (специальные устройства, вентилятор).  
✔ Громкие звуки **могут разбудить ребёнка** – старайтесь не шуметь в ночное время.  

🚨 **Чего нельзя делать?**  
🚫 Оставлять включённую музыку или телевизор на всю ночь.  
🚫 Громко разговаривать в одной комнате с малышом.  

---
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сон'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SectionButton(
            title: 'Режим сна',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InfoScreen(
                    title: 'Режим сна',
                    markdownContent: sleepRegimenContent,
                  ),
                ),
              );
            },
          ),
          SectionButton(
            title: 'Безопасность во время сна',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InfoScreen(
                    title: 'Безопасность во время сна',
                    markdownContent: sleepSafetyContent,
                  ),
                ),
              );
            },
          ),
          SectionButton(
            title: 'Создание комфортной обстановки',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InfoScreen(
                    title: 'Создание комфортной обстановки',
                    markdownContent: sleepEnvironmentContent,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SectionButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const SectionButton({Key? key, required this.title, required this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFFC8E6C9), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
