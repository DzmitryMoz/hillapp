import 'package:flutter/material.dart';
import 'info_screen.dart';

class BabyCareHygieneScreen extends StatelessWidget {
  const BabyCareHygieneScreen({Key? key}) : super(key: key);

  // Markdown для каждого подпункта
  final String dailyHygieneContent = '''
# **Правила ежедневного ухода за новорождённым** 👶🍼

Ежедневный уход за новорождённым необходим не только для поддержания **гигиены и комфорта**, но и для профилактики различных заболеваний. Гигиенические процедуры проводят **утром перед первым кормлением** и в течение дня **по мере необходимости**.

---

## **🌿 1. Утренний туалет новорождённого**

Утренняя гигиена включает:  
✔ Умывание лица.  
✔ Обработку глаз.  
✔ Очищение носовых ходов и ушей.  
✔ Обработку кожных складок.  
✔ Подмывание.  

### **👀 Обработка глаз**
🔹 Каждый глаз протирают **от наружного уголка к переносице** отдельным **ватным диском, смоченным в кипячёной воде** или физрастворе.  
🔹 После обработки **глазки промакивают** чистыми салфетками.  
🔹 В течение дня **промывание глаз проводят по мере необходимости** (при появлении слизистых выделений).  

---

## **👃 Очищение носа**
✔ Носовые ходы новорождённого иногда требуют **регулярной очистки** от слизи и сухих корочек.  

📌 **Как правильно очищать нос:**  
1️⃣ Скрутите **ватный жгутик** и смочите его вазелиновым или растительным маслом.  
2️⃣ Осторожно введите жгутик **в носовой ход на 1-1,5 см** и совершайте **вращательные движения**.  
3️⃣ Используйте **отдельный жгутик для каждой ноздри**.  
4️⃣ Не проводите процедуру слишком долго, чтобы **не раздражать слизистую**.  

❗ **Что нельзя делать:**  
🚫 Использовать ватные палочки – они могут травмировать носик.  
🚫 Чистить нос слишком глубоко.  

---

## **👂 Уход за ушами**
✔ Чистят **только наружную часть уха** – ушную раковину и область за ухом.  
✔ Используйте **ватный диск или мягкую ткань**.  
✔ **Не очищайте слуховой проход!**  

❗ **Важно:**  
- Если выделений в ушах много, лучше **проконсультироваться с врачом**.  
- **Не используйте ватные палочки**, так как они могут протолкнуть серу глубже.  

---

## **✂️ Уход за ногтями**
✔ Ногти **на руках стригут раз в 3-5 дней**, а на **ногах – раз в 7-10 дней**.  
✔ Для стрижки используют **специальные детские ножницы** с закруглёнными кончиками.  
✔ В первые дни жизни можно надевать **антицарапки** для предотвращения повреждений.  

📌 **Как правильно стричь ногти:**  
1️⃣ Стригите **в светлом помещении**.  
2️⃣ Подождите, пока ребёнок **уснёт** – так он не будет дёргать ручками.  
3️⃣ Обрезайте **ногти на руках по округлой форме**, а **на ногах – по прямой**.  
4️⃣ После стрижки можно **обработать края пилочкой**.  

---

## **🩹 Уход за пупочной ранкой**
✔ Пуповинный остаток **высыхает и отпадает** в течение **первой недели жизни**.  
✔ Важно **держать ранку сухой и чистой**.  

📌 **Что делать:**  
✔ Обрабатывать **1 раз в день** после купания.  
✔ Промывать **тёплой кипячёной водой** при загрязнении.  
✔ Высушивать **марлевой салфеткой**.  

❗ **Чего нельзя делать:**  
🚫 Нельзя применять **спирт, зелёнку или марганцовку** – они могут замедлить заживление.  
🚫 Не удаляйте пуповинный остаток насильно!  

📌 **Признаки инфекции (требуют срочного обращения к врачу):**  
🚨 Покраснение или отёк вокруг пупка.  
🚨 Гнойные выделения с неприятным запахом.  
🚨 Повышение температуры. 
''';

  final String bathingContent = '''
# **🛁 Купание новорождённого** 👶🚿

Купание – это не только **гигиеническая процедура**, но и способ **расслабить малыша**, помочь ему адаптироваться к новой среде и **укрепить связь с родителями**.  

## **🌿 1. Когда можно начинать купать новорождённого?**
✔ **Купание можно начинать сразу после выписки из роддома**, если педиатр не дал других рекомендаций.  
✔ Если **пупочная ранка не зажила**, первые две недели купание проводят в кипячёной воде или с добавлением слабого раствора марганцовки.  
✔ **Если ребёнок вакцинирован БЦЖ**, купание лучше **отложить на сутки**.  

---

## **📌 2. Основные правила купания**
✔ Купать **ежедневно или через день** – вечером перед сном.  
✔ Длительность **5-10 минут** для первых купаний, постепенно увеличивается.  
✔ Температура воды **36,5-37,0°C**.  
✔ Температура воздуха в комнате **не ниже 22-24°C**.  
✔ Использовать **специальные средства для купания не чаще 1-2 раз в неделю**.  
✔ Первые 1-2 недели купание лучше проводить в **отдельной детской ванночке**.  

🚨 **Чего нельзя делать?**  
🚫 Купать малыша сразу после кормления.  
🚫 Использовать горячую воду (опасность ожогов).  
🚫 Добавлять в воду **сильнодействующие антисептики** без рекомендации врача.  
🚫 Использовать **мыло и шампуни слишком часто** – это может пересушить кожу малыша.  

---

## **🛀 3. Как подготовить ванночку для купания?**
📌 **Что понадобится:**  
✔ **Детская ванночка** (или чистая большая ванна).  
✔ **Термометр для воды**.  
✔ **Кувшин с чистой водой** для ополаскивания.  
✔ **Махровое полотенце** (лучше с капюшоном).  
✔ **Детское гипоаллергенное средство для купания**.  
✔ **Ватные диски** и мягкая пелёнка.  

📌 **Подготовка воды:**  
✔ Используйте **тёплую проточную воду** (если пупочная ранка зажила).  
✔ В первые 2 недели – **кипячёную воду**.  
✔ При необходимости можно добавить **ромашку, череду или слабый раствор марганцовки**.  

🚨 **Важно!**  
✔ Не оставляйте ребёнка **одного в воде**!  
✔ Перед купанием **проверьте температуру воды рукой или термометром**.  
✔ Если вода **остыла во время купания**, подливайте только **тёплую воду**.  

---

## **💦 4. Порядок купания новорождённого**
📌 **Пошаговая инструкция:**
1️⃣ **Разденьте малыша**, оставив подгузник, и оботрите складочки влажной салфеткой.  
2️⃣ **Аккуратно положите его в воду**, поддерживая **голову и шею**.  
3️⃣ **Сначала обмойте личико** чистой водой без мыла.  
4️⃣ **Обмойте тело малыша** – используйте мягкую губку или ладонь.  
5️⃣ **Ополосните волосы** – **не наклоняя голову назад!**  
6️⃣ **Ополосните тело тёплой чистой водой из кувшина**.  
7️⃣ **Аккуратно выньте малыша**, завернув его в тёплое полотенце.  

🚨 **Помните!**  
✔ Держите малыша **надёжно**, особенно **под шею и голову**.  
✔ Если ребёнок **боится воды**, начните с **обтираний влажной тканью**.  

---

## **🧴 5. Уход после купания**
📌 **Что делать после ванны?**
✔ **Аккуратно промокните кожу** (не растирайте!).  
✔ **Обработайте пупочную ранку**, если она ещё не зажила.  
✔ **Нанесите увлажняющий крем или масло** на складочки.  
✔ **Оставьте малыша без подгузника** на 5-10 минут (воздушные ванны).  
✔ **Оденьте в хлопковую одежду**, чтобы кожа дышала.  

🚨 **Когда купание не рекомендуется?**  
✔ При высокой температуре у ребёнка.  
✔ При кожных высыпаниях (по рекомендации врача).  
✔ В день вакцинации (если врач не дал разрешение).  

---

## **🛁 6. Какие средства можно добавлять в воду?**
✔ **Ромашка** – снимает раздражение и воспаление.  
✔ **Череда** – помогает при опрелостях и аллергических высыпаниях.  
✔ **Календула** – заживляет мелкие повреждения.  
✔ **Детская соль для купания** – расслабляет мышцы.  

🚨 **Чего нельзя добавлять?**  
🚫 Эфирные масла (они могут вызвать аллергию).  
🚫 Крахмал (может забить поры кожи).  
🚫 Спирт и марганцовку в высокой концентрации.  

---

## **🌟 7. Советы для комфортного купания**
✔ **Купайте малыша в одно и то же время** – это поможет сформировать режим.  
✔ **Разговаривайте с ребёнком** во время купания – это его успокаивает.  
✔ **Используйте плавательные круги** (после 1 месяца) для активных движений.  
✔ **Пробуйте делать водные массажи** – это улучшает кровообращение.  
✔ **Если ребёнок боится воды**, попробуйте **купать его вместе с мамой** – это помогает снизить тревожность.  

---

## **📌 Заключение**
Купание – это **не только гигиена, но и важный ритуал**, который помогает малышу **расслабиться, укрепить кожу и мышцы, улучшить сон**.  

✔ Соблюдайте **температурный режим воды и воздуха**.  
✔ Используйте **натуральные средства ухода**.  
✔ Будьте **осторожны и внимательны** к реакции малыша.  

''';

  final String skinCareContent = '''
# **🧴 Уход за кожей новорождённого** 👶💖

Кожа новорождённого **очень нежная и чувствительная**, поэтому требует особого ухода. **Регулярные гигиенические процедуры** помогут **предотвратить раздражения, воспаления и аллергические реакции**.

---

## **🌿 1. Особенности кожи новорождённого**
✔ Кожа **тоньше и чувствительнее**, чем у взрослых.  
✔ Имеет **слабый защитный барьер**, поэтому склонна к раздражениям и воспалениям.  
✔ В первые недели возможны **шелушения** – это нормальный процесс адаптации кожи.  
✔ Склонна к **перегреву и пересыханию**, поэтому важно поддерживать **оптимальный уровень влажности**.  

🚨 **Что может навредить коже?**  
❌ Агрессивные моющие средства.  
❌ Частое использование мыла и антисептиков.  
❌ Перегрев или сухой воздух в комнате.  
❌ Ношение синтетической одежды.  
❌ Неправильный выбор подгузников.  

---

## **🛁 2. Гигиена кожи: правила ухода**
✔ **Купание каждый день или через день** – помогает поддерживать чистоту кожи.  
✔ Использовать **гипоаллергенные средства** не чаще **1-2 раз в неделю**.  
✔ После купания **кожу промакивать полотенцем** (не растирать!).  
✔ **Воздушные ванны 5-10 минут** после каждой смены подгузника.  
✔ Увлажнение кожи **кремами или маслами** (по необходимости).  

📌 **Важно:**  
✔ Вода для купания должна быть **36-37°C**.  
✔ Влажность в комнате **40-60%**, температура **22-24°C**.  
✔ Не используйте **мыло чаще 1-2 раз в неделю**, так как оно **разрушает защитный слой кожи**.  

---

## **🩷 3. Шелушение кожи у новорождённого**
В первые дни жизни кожа новорождённого **может шелушиться** – это **нормальный процесс**, который не требует специального лечения.  

📌 **Что делать при шелушении?**  
✔ После купания **наносить увлажняющий крем или детское масло**.  
✔ Увлажнять воздух в комнате (**40-60% влажности**).  
✔ **Не использовать присыпку и агрессивные кремы** без необходимости.  
✔ Избегать **жёстких тканей и синтетической одежды**.  

🚨 **Чего нельзя делать?**  
🚫 Очищать кожу спиртом или агрессивными антисептиками.  
🚫 Снимать шелушащиеся участки вручную.  
🚫 Использовать мыло и шампуни слишком часто.  

---

## **🎀 4. Уход за кожными складками**
Кожные складки **особенно подвержены раздражению**, поэтому за ними требуется тщательный уход.  

📌 **Что делать?**  
✔ После купания тщательно **высушивать складки** полотенцем.  
✔ Использовать **увлажняющие средства (лосьон, крем, масло)**.  
✔ При покраснении – применять **специальные кремы с пантенолом**.  
✔ Давать коже "дышать" – **чаще оставлять малыша без одежды**.  

🚨 **Что нельзя делать?**  
🚫 Посыпать складки тальком или присыпкой – это может вызвать закупорку пор.  
🚫 Оставлять кожу влажной после купания – это создаёт среду для размножения бактерий.  

---

## **🩲 5. Уход за кожей в области подгузника**
Подгузники создают **влажную среду**, которая может провоцировать раздражения и пеленочный дерматит.  

📌 **Как правильно ухаживать?**  
✔ Менять подгузник **каждые 2-3 часа** или сразу после дефекации.  
✔ Очищать кожу **тёплой водой или влажными салфетками без спирта**.  
✔ Давать коже "дышать" **5-10 минут после смены подгузника**.  
✔ Использовать **крем под подгузник** при необходимости.  

🚨 **Когда обращаться к врачу?**  
✔ Если **покраснение не проходит в течение 2-3 дней**.  
✔ Если появляются **гнойнички или пузырьки**.  
✔ Если кожа **отекает или покрывается сыпью**.  

---

## **🌿 6. Как предотвратить пелёночный дерматит?**
Пелёночный дерматит – **раздражение кожи в области подгузника**.  

📌 **Как избежать?**  
✔ Часто **менять подгузник**.  
✔ Использовать **"дышащие" подгузники**.  
✔ Регулярно **проветривать кожу малыша**.  
✔ При покраснении – наносить **барьерный крем (с цинком, пантенолом)**.  

🚨 **Когда срочно к врачу?**  
✔ Если **покраснение не проходит больше 3 дней**.  
✔ Если появились **гнойнички, трещины или мокнущие раны**.  

---

## **🛡 7. Уход за кожей головы (гнейс, молочные корочки)**
У многих новорождённых на голове появляются **молочные корочки (гнейс)** – это **нормальное состояние** и не является признаком аллергии.  

📌 **Как ухаживать?**  
✔ За 30 минут до купания **нанести детское масло на корочки**.  
✔ Во время купания **мягко помассировать голову влажной губкой**.  
✔ После купания **убрать корочки мягкой щёточкой**.  
✔ Если корочки не проходят – **обратиться к врачу**.  

🚨 **Чего нельзя делать?**  
🚫 Сдирать корочки ногтями.  
🚫 Использовать спиртовые растворы или мыло.  

---

## **🌿 8. Гигиена кожи лица**
Кожа лица особенно чувствительная, поэтому за ней нужен **бережный уход**.  

📌 **Что делать?**  
✔ Умывать ребёнка **тёплой кипячёной водой** 1-2 раза в день.  
✔ При загрязнениях **использовать ватные диски, смоченные в воде**.  
✔ При раздражении **наносить детский крем**.  

🚨 **Чего нельзя делать?**  
🚫 Очищать кожу спиртом, мылом или влажными салфетками с отдушками.  
🚫 Тереть кожу полотенцем после умывания.  

---

## **📌 Заключение**
Кожа новорождённого **очень чувствительна**, поэтому важно:  
✔ Использовать **натуральные средства ухода**.  
✔ Избегать **раздражающих факторов**.  
✔ Регулярно **проводить гигиенические процедуры**.  
✔ Следить за **влажностью и температурой воздуха**.  

💖 **Здоровая кожа – залог комфорта и хорошего самочувствия малыша!**  

''';



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Гигиенический уход'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SectionButton(
            title: 'Ежедневный туалет',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InfoScreen(
                    title: 'Ежедневный туалет',
                    markdownContent: dailyHygieneContent,
                  ),
                ),
              );
            },
          ),
          SectionButton(
            title: 'Купание',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InfoScreen(
                    title: 'Купание',
                    markdownContent: bathingContent,
                  ),
                ),
              );
            },
          ),
          SectionButton(
            title: 'Уход за кожей',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InfoScreen(
                    title: 'Уход за кожей',
                    markdownContent: skinCareContent,
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
        // Пример градиента (фиолетово-розовый)
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
