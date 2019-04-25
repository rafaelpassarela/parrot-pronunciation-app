import 'package:http/http.dart' as http;

class HttpController {

  Future<String> createPost(
      String url,
      {
        String body,
        Function(http.Response) thenCallback,
        Function() errorCallback
      }
  ) async {
    return http.post(url, body: body).then(
      (http.Response response) {
        thenCallback(response);
        return response.body;
      }).catchError(
            (error) => errorCallback()
    );
  }

}