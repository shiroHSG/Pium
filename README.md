# 🌸 PIU-M (피움) 🌸

---

# 📌 프로젝트 소개

**"피어나는 마음"**  
2030세대 부모의 육아에 필요한 **커뮤니티, 일정, 정책, 나눔 기능**을 하나로 통합한 앱입니다.  
모바일 최적화 UX와 **지역 기반 커뮤니티**를 통해 누구나 쉽고 꾸준히 사용할 수 있는  
**2030 부모 맞춤형 통합 지원 플랫폼**을 목표로 개발했습니다.

* 🔍 **주제**: 2030 부모를 위한 지역 기반 육아 지원 플랫폼  
* 🧠 **기획의도**: 단편화된 육아 정보, 중고거래 신뢰 문제, 정책 접근성 부족 해결  
* 🛠 **기술스택**:  
  * FE : Flutter  
  * BE : Java, Spring Boot, Spring Security, JPA  
  * DB : MySQL  
  * Infra : AWS EC2, RDS, S3, Nginx Reverse Proxy  
  * VCS & CI/CD : Git, GitHub, GitHub Actions, S3 배포  

---

## 👨‍👩‍👧‍👦 팀원 소개

| 이름   | 역할             | 담당 업무                                   |
| ------ | ---------------- | ------------------------------------------- |
| 최태동 | 백엔드 / 프론트엔드 | 공동관리 기능, API 설계, Flutter UI 개발 |
| 한수연 | 프론트엔드         | UI/UX 설계, Flutter 앱 개발               |
| 한정환 | 백엔드 / 프론트엔드 | 정책 정보, 커뮤니티 기능, 앱 연동         |
| 홍성관 | 백엔드            | 회원 관리, 채팅, 배포/CI-CD               |

---

## ✨ 주요 기능

### 👨‍👩‍👦 공동 관리 기능
* 아이 정보 등록 및 공유
* 육아일지 작성 / 수정
* 공유 캘린더 (일정 관리)
* 메이트 기반 육아 관리

### 💬 소통 기능
* 커뮤니티 게시판
* 품앗이 / 나눔 기능
* 실시간 채팅 (WebSocket)

### 📑 정보 제공 기능
* 정부 육아 정책 통합 제공
* 맞춤형 정책 필터링

---

## 🖥️ 서비스 아키텍처

![아키텍처](https://github.com/user-attachments/assets/e30bc9ff-658c-483d-abe0-c4d142c13e5e)

---

## 🎨 UI/UX 화면 설계

![UI/UX](https://github.com/user-attachments/assets/02c6f0d8-73a1-4c1d-b86e-81d964ce5c80)

---

## 🗃 ERD

![ERD](https://github.com/user-attachments/assets/76e40e8b-d25b-43af-a1cc-193a4e8e756e)

---

## 📹 시연 영상

[![Watch the video](https://img.youtube.com/vi/WKDH92otQ6I/0.jpg)](https://www.youtube.com/watch?v=WKDH92otQ6I)

---

## ✅ 실행 방법
api 서버를 ec2에 배포 후 app은 따로 설치해야 하는데 서버는 비용 문제로 내렸습니다

[pium.zip](https://github.com/user-attachments/files/22400477/pium.zip)

