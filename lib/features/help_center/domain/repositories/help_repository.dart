import 'package:auto_hub_app/core/errors/failures.dart';
import 'package:auto_hub_app/features/help_center/models/help_article.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class HelpRepository {
  Future<Either<Failure, List<String>>> getCategories();
  Future<Either<Failure, List<HelpArticle>>> getArticles({String? category, String? query});
  Future<Either<Failure, Map<String, dynamic>>> createTicket({
    required String category,
    required String subject,
    required String description,
    String? orderId,
    List<String>? attachments,
  });
  Future<Either<Failure, Map<String, dynamic>>> requestCallback({
    required String phone,
    String? preferredTime,
  });
}

