//PostRequest: 클라이언트가 백엔드로 데이터를 보낼 때 (예: 게시글 작성, 게시글 수정) 사용합니다.
// 서버에 저장하거나 처리하기 위해 필요한 최소한의 정보(예: category, title, content, postImg)를 포함합니다.
// 일반적으로 서버가 자동으로 처리할 id, viewCount, createdAt, member 정보 등은 포함하지 않습니다.

class PostRequest {
  final String category;
  final String title;
  final String content;
  // final String? postImg; // 이미지는 선택 사항이므로 nullable로 선언
  final String? imgUrl;

  PostRequest({
    required this.category,
    required this.title,
    required this.content,
    // this.postImg,
    this.imgUrl,
  });

  // Dart 객체를 백엔드가 이해하는 JSON 형식의 Map으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'title': title,
      'content': content,
      // 'postImg' 필드는 null이 아니거나 빈 문자열이 아닐 때만 JSON에 포함됩니다.
      // 백엔드가 postImg에 대해 명시적으로 null을 받는 것을 선호한다면,
      // 단순히 'postImg': postImg, 와 같이 조건을 제거해도 됩니다.
      // if (postImg != null && postImg!.isNotEmpty) 'postImg': postImg,
      'imgUrl': imgUrl,
    };
  }
}