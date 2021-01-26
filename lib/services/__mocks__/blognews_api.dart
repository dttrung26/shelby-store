import '../../common/tools.dart';
import '../wordpress/blognews_api.dart';
import 'mock_constants.dart';

class BlogNewsApiMock extends BlogNewsApi {
  BlogNewsApiMock(url) : super(url);

  @override
  Future<dynamic> getBlogs({page = 1}) async {
    return Utils.parseJsonFromAssets(MockConstants.mockDataBlog);
  }
}
