
##  Hướng dẫn Redmine – Rialo Jump (Python Game)

##1. Giới thiệu
Rialo Jump là một mini-game được xây dựng bằng Python + Pygame, lấy cảm hứng từ mascot/logo của dự án Rialo.
Người chơi điều khiển logo Rialo nhảy qua các chướng ngại vật để ghi điểm.
Repo này được dùng để tham gia cuộc thi/game showcase cho cộng đồng.


##2. Yêu cầu hệ thống
•	Python >= 3.10 (tested với 3.13.7)
•	Pygame >= 2.0
•	Hệ điều hành: Windows / Linux / macOS


##3. Cài đặt môi trường
Clone repo về máy:
git clone https://github.com/<username>/rialo-jump.git
cd rialo-jump
Cài đặt thư viện:
python -m pip install --upgrade pip
python -m pip install pygame


##4. Cách chạy game
Trong thư mục gốc (có file rialo_logo.png), chạy lệnh:
python rialo_jump.py
Game sẽ mở cửa sổ 800x400, trong đó:
•	Nhấn SPACE để nhảy.
•	Tránh chướng ngại vật màu đen.
•	Mỗi lần vượt qua chướng ngại vật, bạn sẽ +1 điểm.
•	Nếu va chạm → Game Over.


##5. Cấu trúc thư mục
rialo-jump/
│── rialo_jump.py         # Code chính của game
│── rialo_logo.png        # Logo Rialo (nhân vật chính)
│── README.md             # Hướng dẫn dự án


##6. Demo Screenshot (tuỳ chọn)
(Bạn có thể chụp màn hình game đang chạy, thêm vào repo để minh họa).

##7. License
MIT License – bạn có thể sử dụng, chia sẻ và tùy chỉnh tự do.


