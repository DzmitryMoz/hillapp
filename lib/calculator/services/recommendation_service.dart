// lib/calculator/services/recommendation_service.dart

class RecommendationService {
  String getRecommendation(String medicationId) {
    switch (medicationId) {
      case 'med1':
        return 'Если температура не снижается, обратитесь к врачу.';
      case 'med2':
        return 'Не превышайте рекомендованную дозу и частоту приёма.';
    // Добавьте другие рекомендации по необходимости
      default:
        return 'Следуйте инструкциям на упаковке лекарства.';
    }
  }
}
