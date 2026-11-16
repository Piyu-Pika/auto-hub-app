import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/errors/failures.dart';
import 'package:auto_hub_app/features/help_center/data/datasources/help_remote_datasource.dart';
import 'package:auto_hub_app/features/help_center/domain/repositories/help_repository.dart';
import 'package:auto_hub_app/features/help_center/models/help_article.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: HelpRepository)
class HelpRepositoryImpl implements HelpRepository {
  HelpRepositoryImpl(this._remoteDatasource);

  final HelpRemoteDatasource _remoteDatasource;

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    try {
      final list = await _remoteDatasource.getCategories();
      if (list.isNotEmpty) return Right(list);
      return const Right(['All', 'Junking', 'Orders', 'Parts', 'Payments']);
    } catch (_) {
      return const Right(['All', 'Junking', 'Orders', 'Parts', 'Payments']);
    }
  }

  @override
  Future<Either<Failure, List<HelpArticle>>> getArticles({
    String? category,
    String? query,
  }) async {
    try {
      final articles = await _remoteDatasource.getArticles(
        category: category,
        query: query,
      );
      if (articles.isNotEmpty) return Right(articles);
      return Right(HelpArticle.defaultArticles);
    } catch (_) {
      return Right(HelpArticle.defaultArticles);
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createTicket({
    required String category,
    required String subject,
    required String description,
    String? orderId,
    List<String>? attachments,
  }) async {
    try {
      final res = await _remoteDatasource.createTicket(
        category: category,
        subject: subject,
        description: description,
        orderId: orderId,
        attachments: attachments,
      );
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> requestCallback({
    required String phone,
    String? preferredTime,
  }) async {
    try {
      final res = await _remoteDatasource.requestCallback(
        phone: phone,
        preferredTime: preferredTime,
      );
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

