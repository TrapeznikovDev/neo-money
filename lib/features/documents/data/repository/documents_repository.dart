import 'package:neomoney/features/documents/data/models/company_docs_model.dart';

abstract interface class DocumentsRepository {
  Future<CompanyDocsModel> fetchCompanyDocs();
}