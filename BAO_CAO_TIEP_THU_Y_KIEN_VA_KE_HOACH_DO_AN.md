# BẢN THUYẾT MINH KIẾN TRÚC TỔNG THỂ HỆ THỐNG THUẦN CLOUD-NATIVE & GITOPS

> **Học phần**: NT114.R11 - Đồ án chuyên ngành (Học kỳ 1, Năm học 2026 - 2027)  
> **Tên đề tài chính thức**: Nghiên cứu và xây dựng nền tảng vận hành ứng dụng microservices trên Kubernetes *(Building a Platform for Deploying and Operating Microservices on Kubernetes)*  
> **Giảng viên hướng dẫn**: ThS. Văn Thiên Luân  
> **Sinh viên thực hiện**:  
> 1. **Đào Đức Thịnh** - MSSV: 23521495 *(Chủ nhiệm đề tài)*  
> 2. **Nguyễn Bá Thiện** - MSSV: 23521480  
> **Hệ thống ứng dụng demo**: Nền tảng quản trị công việc vi dịch vụ mã nguồn mở Plane (`makeplane/plane`)  
> **Định hướng kiến trúc**: **Tối đa hóa việc sử dụng các dịch vụ nền tảng tích hợp sẵn (100% Fully Managed Native Cloud Stack) của Amazon Web Services (AWS)**  

---

## 1. BÀI TOÁN KỸ THUẬT TRỌNG TÂM (PROBLEM STATEMENT)

Hệ thống tập trung giải quyết bài toán vận hành nền tảng quản trị dự án doanh nghiệp quy mô lớn trên nền tảng điện toán đám mây AWS với 4 mục tiêu cốt lõi:
1. **Tận dụng tối đa Dịch vụ Nền tảng Đám mây (Native Cloud Services)**: Thay vì sử dụng Cloud như các máy ảo đơn thuần (IaaS) và tự cài đặt thủ công, đồ án chuyển dịch toàn diện sang các dịch vụ do chính nhà cung cấp Cloud quản lý tự động (**Amazon EKS, Amazon ECR, Amazon RDS, Amazon S3, AWS Secrets Manager**).
2. **Tính sẵn sàng cao (High Availability) & Khả năng chịu lỗi**: Kiến trúc đa vùng khả dụng (**Multi-AZ Architecture**) trải dài qua `us-east-1a` và `us-east-1b`, loại bỏ hoàn toàn các điểm nghẽn đơn lẻ (No Single Point of Failure).
3. **Phân tách triệt để Stateless Compute và Stateful Datastores**: Tầng tính toán vi dịch vụ trên Kubernetes hoàn toàn không lưu trạng thái (ephemeral), toàn bộ dữ liệu quan trọng được bảo vệ độc lập bởi các dịch vụ dữ liệu chuyên dụng có độ bền 11 số 9 và tự động sao lưu Point-in-Time.
4. **Tự động hóa toàn diện bằng GitOps & DevSecOps**: Hạ tầng được định nghĩa 100% dưới dạng mã (**Terraform**), quy trình kiểm thử bảo mật tự động (**Trivy**) và triển khai liên tục không gián đoạn dịch vụ (**ArgoCD**).

---

## 2. BÓC TÁCH KIẾN TRÚC & NGHIỆP VỤ ỨNG DỤNG PLANE (`makeplane/plane`)

* **Kho mã nguồn mở gốc (Plane HQ)**: [https://github.com/makeplane/plane](https://github.com/makeplane/plane) *(Hơn 33.000 stars trên GitHub - Nền tảng quản lý dự án và theo dõi tiến độ công việc vi dịch vụ mã nguồn mở hàng đầu thế giới)*.
* **Kho lưu trữ triển khai đồ án (DevOps Platform)**: [https://github.com/DucThinhIsMeX/plane-k8s-microservices-platform](https://github.com/DucThinhIsMeX/plane-k8s-microservices-platform).

### 2.1. Bản chất nghiệp vụ: Ứng dụng Plane giải quyết bài toán gì?
**Plane** là giải pháp mã nguồn mở thay thế trực tiếp cho các nền tảng quản trị công việc thương mại đóng như **Jira, Linear hay Asana**. Ứng dụng phục vụ toàn diện quy trình phát triển phần mềm và quản trị dự án công nghệ:
1. **Quản lý công việc & Vấn đề (Issue & Bug Tracking)**: Tạo, gán việc, phân loại lỗi/tính năng, gắn nhãn (labels), thiết lập mức độ ưu tiên (Urgent, High, Medium, Low) và thời hạn hoàn thành.
2. **Không gian làm việc & Bảng Kanban trực quan (Kanban Boards & Views)**: Cho phép chuyển đổi linh hoạt giữa dạng Danh sách (List), Bảng tính (Spreadsheet), Lịch (Calendar) và Bảng Kanban kéo-thả để theo dõi trạng thái công việc (*Backlog $\to$ Todo $\to$ In Progress $\to$ Done*).
3. **Quản lý chu kỳ phát triển Agile/Scrum (Cycles & Sprints)**: Lập kế hoạch theo từng Sprint, theo dõi tiến độ hoàn thành và phân tích biểu đồ năng suất (Burn-down chart).
4. **Phân hệ chức năng dự án (Modules & Epics)**: Gom nhóm các task thành từng module hoặc tính năng lớn của sản phẩm.
5. **Tài liệu & Đặc tả dự án (Pages & Docs)**: Soạn thảo tài liệu yêu cầu, biên bản họp và tài liệu kiến trúc kỹ thuật trực tiếp trên nền tảng.
6. **Cộng tác thời gian thực (Real-time Collaboration)**: Khi một kỹ sư cập nhật trạng thái thẻ bài trên Kanban hoặc bình luận, màn hình của toàn bộ thành viên trong nhóm tự động cập nhật ngay lập tức mà không cần tải lại trang.

---

### 2.2. Sơ đồ mô hình chức năng & luồng nghiệp vụ của ứng dụng Plane

Sơ đồ thể hiện trực quan vai trò người dùng, các phân hệ chức năng nghiệp vụ của Plane và cách các vi dịch vụ bên dưới hiện thực hóa các tính năng đó:

```mermaid
flowchart TB
    %% NHÓM NGƯỜI DÙNG DOANH NGHIỆP
    subgraph USERS[" 👥 NHÓM NGƯỜI DÙNG & VAI TRÒ DOANH NGHIỆP "]
        direction LR
        PM["👔 Quản lý Dự án (PM / PO)"]
        DEV["👨‍💻 Kỹ sư Phát triển (Dev / DevOps)"]
        QA["🐞 Kỹ sư Kiểm thử (QA / Tester)"]
    end

    %% CÁC TÍNH NĂNG NGHIỆP VỤ CỐT LÕI CỦA ỨNG DỤNG PLANE
    subgraph APP_FEATURES[" 📋 NỀN TẢNG QUẢN TRỊ DỰ ÁN & TIẾN ĐỘ PLANE (BUSINESS CAPABILITIES) "]
        direction TB

        subgraph F_KANBAN[" 1. Quản Trị Công Việc Trực Quan "]
            direction LR
            FEAT_KANBAN["📊 Bảng Kanban kéo-thả<br/>(Backlog -> In Progress -> Done)"]
            FEAT_ISSUES["🐛 Theo dõi Task & Lỗi<br/>(Gán người làm, độ ưu tiên, deadline)"]
        end

        subgraph F_AGILE[" 2. Quy Trình Agile & Quản Lý "]
            direction LR
            FEAT_CYCLES["🔄 Chu kỳ Sprint (Cycles)<br/>(Kế hoạch & Đo lường Burn-down)"]
            FEAT_MODULES["🧩 Phân hệ tính năng (Modules)<br/>(Quản lý tính năng lớn / Epics)"]
        end

        subgraph F_COLLAB[" 3. Tài Liệu & Cộng Tác "]
            direction LR
            FEAT_DOCS["📝 Wiki & Pages dự án<br/>(Soạn thảo tài liệu đặc tả)"]
            FEAT_REALTIME["⚡ Cộng tác thời gian thực<br/>(Nhận thông báo, cập nhật Kanban tức thì)"]
        end
    end

    %% CÁC VI DỊCH VỤ VẬN HÀNH BÊN DƯỚI (EKS PODS)
    subgraph MICROSERVICES[" ⚙️ CÁC VI DỊCH VỤ THỰC THI CHỨC NĂNG (KUBERNETES PODS) "]
        direction TB
        SVC_WEB["plane-frontend (Next.js)<br/>Cung cấp giao diện Web, Kanban, Pages"]
        SVC_LIVE["plane-live (Node.js WebSocket)<br/>Đồng bộ hóa tức thì các thao tác kéo-thả"]
        SVC_API["plane-api (Django REST Core)<br/>Xử lý toàn bộ logic nghiệp vụ, phân quyền"]
        SVC_WORKER["plane-worker & beat (Celery)<br/>Gửi email thông báo, xuất báo cáo, tác vụ ngầm"]
        SVC_CACHE[("plane-redis<br/>Bộ nhớ đệm & Kênh truyền tin thời gian thực")]
    end

    %% TẦNG LƯU TRỮ DỮ LIỆU ĐÁM MÂY (AWS NATIVE PAAS)
    subgraph DATA_STORAGE[" ☁️ TẦNG LƯU TRỮ DỮ LIỆU BỀN VỮNG (AWS MANAGED SERVICES) "]
        direction LR
        DB[("🗄️ Amazon RDS PostgreSQL 16.3<br/>Lưu thông tin Dự án, Thành viên, Tasks, Sprints, Comments")]
        STORAGE["📦 Amazon S3 Bucket<br/>Lưu trữ Tài liệu đính kèm, Ảnh chụp lỗi (Screenshots), Avatars")]
    end

    %% TƯƠNG TÁC NGHIỆP VỤ
    USERS ==>|Truy cập qua trình duyệt| SVC_WEB
    SVC_WEB -->|Hiển thị & Tương tác| APP_FEATURES

    FEAT_KANBAN & FEAT_ISSUES & FEAT_CYCLES & FEAT_MODULES & FEAT_DOCS -->|Gọi REST API| SVC_API
    FEAT_REALTIME <-->|Kết nối WebSocket thời gian thực| SVC_LIVE

    SVC_LIVE <-->|Pub/Sub sự kiện realtime| SVC_CACHE
    SVC_API <-->|Đẩy sự kiện & Lưu phiên cache| SVC_CACHE
    SVC_CACHE -->|Rút tác vụ bất đồng bộ| SVC_WORKER

    SVC_API ==>|Lưu trữ & Truy vấn dữ liệu nghiệp vụ| DB
    SVC_WORKER ==>|Cập nhật trạng thái tác vụ nền| DB

    SVC_API ==>|Tải / Xuất tệp đính kèm| STORAGE
    SVC_WORKER ==>|Lưu trữ báo cáo xuất bản| STORAGE
```

---

### 2.3. Bảng quy hoạch bóc tách thành phần với AWS Native Services

| Thành phần của Plane | Công nghệ nền tảng | Dịch vụ AWS Native đảm nhiệm | Lợi thế kỹ thuật vượt trội |
| :--- | :--- | :--- | :--- |
| **`plane-frontend`** | Next.js / React Router | **Amazon EKS (Stateless Pods)** | Tự động nhân bản co giãn từ 2 đến 5 Pods bằng HPA theo lưu lượng truy cập thực tế. |
| **`plane-api`** | Django REST (Python) | **Amazon EKS (Stateless Pods)** | Xử lý logic nghiệp vụ, kết nối bảo mật tới RDS qua Private Subnet. |
| **`plane-live`** | Node.js / Socket.IO | **Amazon EKS (Stateless Pods)** | Duy trì kết nối WebSocket thời gian thực cho tính năng cộng tác Kanban. |
| **`plane-worker` & `beat`** | Celery Worker & Scheduler | **Amazon EKS (Stateless Pods)** | Xử lý tác vụ bất đồng bộ (email, webhook, export dữ liệu) rút từ hàng đợi Redis. |
| **`plane-migrator`** | Django DB Migrations | **Amazon EKS (K8s Job)** | Tự động nâng cấp schema database trên RDS trước khi API khởi động. |
| **Container Images** | Docker Multi-arch | **Amazon ECR (Elastic Container Registry)** | Quét lỗ hổng tự động khi push (`scan_on_push`), mã hóa AES256, vòng đời tự xóa ảnh cũ. |
| **Cơ sở dữ liệu quan hệ** | PostgreSQL 16.3 Engine | **Amazon RDS PostgreSQL** | Đặt trong Private DB Subnet Group (Multi-AZ), Automated Daily Backups PITR, Storage Auto-scaling 20GB $\to$ 50GB. |
| **Lưu trữ tệp tin & Media** | Object Storage API | **Amazon S3 Bucket** | Lưu trữ avatar, file đính kèm với độ bền 99.999999999% (11 số 9), tích hợp CORS và Pre-signed URLs. |
| **Bảo mật & Credentials** | API Keys & DB Passwords | **AWS Secrets Manager** | Quản lý mật khẩu tập trung, mã hóa bằng AWS KMS, không lưu mật khẩu tĩnh trong mã nguồn. |
| **Cân bằng tải & Ingress** | HTTP/HTTPS Traffic | **AWS Application Load Balancer (ALB)** | Cân bằng tải Layer 7 thông minh, định tuyến URL path (`/`, `/api`, `/live`), tích hợp SSL/TLS. |

---

## 3. SƠ ĐỒ KIẾN TRÚC TỔNG THỂ DUY NHẤT (MASTER ARCHITECTURE)

Sơ đồ thể hiện luồng tích hợp liền mạch giữa **Quy trình GitOps (CI/CD)**, **Hệ sinh thái Thuần AWS Cloud-Native** và **Tầng Vi Dịch Vụ Plane**:

```mermaid
flowchart TB
    %% PHẦN 1: QUY TRÌNH GITOPS VÀ CI/CD
    subgraph SEC_GITOPS[" 1. QUY TRÌNH TỰ ĐỘNG HÓA GITOPS (CI/CD & DEVSECOPS) "]
        direction TB
        DEV["👨‍💻 Nhóm Kỹ sư DevOps"]
        REPO_APP["📦 GitHub Repo: Mã nguồn Plane (apps/)"]
        REPO_GITOPS["⚙️ GitHub Repo: K8s Manifests (k8s/)"]

        subgraph SEC_CI[" Pipeline Continuous Integration (GitHub Actions) "]
            CI_LINT["Lint Python Code (Flake8)"]
            CI_SEC["Trivy Security Vulnerability Scan"]
            CI_BUILD["Build Multi-arch Container Image"]
            CI_PUSH["Push Image to Amazon ECR"]
            CI_TAG["Tự động cập nhật Image Tag vào GitOps Repo"]
        end

        subgraph SEC_CD[" Pipeline Continuous Delivery (ArgoCD GitOps) "]
            ARGOCD_CTRL["ArgoCD Controller<br/>(Lắng nghe nhánh main)"]
            ARGOCD_SYNC["Tự động đồng bộ trạng thái mong muốn<br/>(Auto-Sync & Self-Healing)"]
        end

        DEV -->|git push code| REPO_APP
        REPO_APP --> CI_LINT --> CI_SEC --> CI_BUILD --> CI_PUSH
        CI_PUSH --> CI_TAG
        CI_TAG -->|commit new tag| REPO_GITOPS
        REPO_GITOPS -.->|Polling / Webhook| ARGOCD_CTRL
        ARGOCD_CTRL --> ARGOCD_SYNC
    end

    %% PHẦN 2: HẠ TẦNG CLOUD AWS
    subgraph SEC_AWS[" 2. HẠ TẦNG THUẦN AWS CLOUD-NATIVE (VPC 10.0.0.0/16 MULTI-AZ) "]
        direction TB

        subgraph PUBLIC_ZONE[" Vùng Mạng Công Khai (Public Subnets: us-east-1a & us-east-1b) "]
            ALB["AWS Application Load Balancer (ALB)<br/>Định tuyến Layer 7 (Ports 80 & 443)"]
            BASTION["Edge / Bastion Node (SSH an toàn)"]
            RANCHER["Rancher Server Dashboard (Quản trị tập trung)"]
        end

        subgraph SEC_ECR[" Tầng Quản Lý Container Image "]
            ECR[("📦 Amazon ECR (Elastic Container Registry)<br/>- Repositories: frontend, api, live, worker, beat<br/>- Image Scanning on Push (Quét lỗ hổng tự động)<br/>- Mã hóa AES256 & Lifecycle Policy")]
        end

        subgraph PRIVATE_ZONE[" Vùng Mạng Nội Bộ (Private Subnets) - Tầng Tính Toán Phân Tán "]
            subgraph EKS_CLUSTER[" Cụm Amazon EKS v1.31 (Managed Kubernetes Cluster) "]
                EKS_CP["AWS Managed EKS Control Plane<br/>(API Server, etcd, Scheduler do AWS vận hành 24/7)"]
                ALB_CTRL["AWS Load Balancer Controller<br/>(Tự động quản lý Ingress & Target Groups)"]
                METRICS["Metrics-Server<br/>(Thu thập tài nguyên Pods)"]

                subgraph EKS_NODES[" EKS Managed Node Group (t3.medium Multi-AZ) "]
                    POD_FRONTEND["plane-frontend (Next.js Web)<br/>[HPA Auto-scaling: 2 - 5 Pods]"]
                    POD_API["plane-api (Django REST Core)<br/>[HPA Auto-scaling: 2 - 5 Pods]"]
                    POD_LIVE["plane-live (Node.js WebSocket)"]
                    POD_WORKER["plane-worker (Celery Async Tasks)"]
                    POD_BEAT["plane-beat (Celery Scheduler)"]
                    POD_MIGRATOR["plane-migrator (K8s Migration Job)"]
                    POD_REDIS[("plane-redis (Cache, Broker & Pub/Sub)")]
                    ARGOCD_APP["ArgoCD Server & Agents"]
                end
            end
        end

        subgraph PAAS_ZONE[" Vùng Dịch Vụ Nền Tảng Dữ Liệu Chuyên Dụng (AWS Managed PaaS) "]
            RDS_DB[("🗄️ Amazon RDS PostgreSQL 16.3<br/>- DB Subnet Group (Multi-AZ: us-east-1a & 1b)<br/>- Automated Daily Backups & Point-in-Time Recovery<br/>- Storage Auto-scaling (20GB -> 50GB gp3)")]
            S3_STORE["📦 Amazon S3 Bucket<br/>- Lưu trữ hình ảnh, avatars, tài liệu đính kèm<br/>- Độ bền dữ liệu 99.999999999% (11 số 9)<br/>- Cấu hình CORS & Mã hóa AES256"]
            SECRETS["🔐 AWS Secrets Manager<br/>- Quản lý mật khẩu DB và API keys<br/>- Tự động mã hóa bằng AWS KMS"]
        end
    end

    %% ĐIỀU HƯỚNG LƯU LƯỢNG VÀ KẾT NỐI
    USERS["🌐 Người Dùng Doanh Nghiệp"] -->|HTTPS Traffic| ALB
    ALB -->|Path: / | POD_FRONTEND
    ALB -->|Path: /api | POD_API
    ALB -->|Path: /live | POD_LIVE

    CI_PUSH -.->|Lưu trữ Docker Images| ECR
    EKS_NODES -.->|Pull images bảo mật| ECR

    ARGOCD_SYNC ==>|Tự động áp dụng Manifests| EKS_NODES
    ALB_CTRL -.->|Quản lý Target Groups cho Pods| ALB
    METRICS -.->|Kích hoạt co giãn HPA| POD_FRONTEND
    METRICS -.->|Kích hoạt co giãn HPA| POD_API

    POD_FRONTEND <--> POD_API
    POD_LIVE <--> POD_API
    POD_API <--> POD_WORKER

    POD_API -.->|Query dữ liệu quan hệ| RDS_DB
    POD_MIGRATOR -.->|Chạy schema migration tự động| RDS_DB
    POD_WORKER -.->|Cập nhật kết quả tác vụ nền| RDS_DB
    POD_WORKER -.->|Lưu file export tài liệu| S3_STORE
    POD_API -.->|Tải/Upload file qua Pre-signed URLs| S3_STORE
    POD_API -.->|Lấy thông tin xác thực an toàn| SECRETS
    POD_API <-->|Cache phiên & Đẩy tác vụ hàng đợi| POD_REDIS
    POD_BEAT -.->|Lên lịch tác vụ định kỳ| POD_REDIS
    POD_WORKER -.->|Rút tác vụ bất đồng bộ| POD_REDIS
    POD_LIVE <-->|Pub/Sub sự kiện WebSocket realtime| POD_REDIS

    RANCHER -.->|Cattle Agent giám sát EKS| EKS_CLUSTER
    BASTION -.->|Quản trị nội bộ an toàn| PRIVATE_ZONE
```

---

## 4. THUYẾT MINH PHÂN BỔ TÀI NGUYÊN & ƯU THẾ CỦA HỆ SINH THÁI AWS NATIVE

Kiến trúc mới giải quyết triệt để vấn đề "dùng Cloud sai tư duy" bằng cách chuyển dịch 100% sang mô hình **Managed Services**:

### 4.1. Tầng Tính Toán Điều Phối Container: Amazon EKS
* **Thay vì tự dựng K8s thủ công trên EC2**: Nhóm sử dụng **Amazon EKS v1.31** — dịch vụ Kubernetes do AWS trực tiếp điều hành và bảo trì tầng Control Plane (`kube-apiserver`, `etcd`, `controller-manager`).
* **Lợi thế kỹ thuật**:
  * Đạt chuẩn **SLA sẵn sàng 99.95%** từ AWS, tự động chuyển đổi dự phòng khi một master node gặp sự cố mà sinh viên không cần can thiệp.
  * Tích hợp **EKS Managed Node Groups** tự động quản lý vòng đời máy ảo Worker Nodes, tự động thay thế instance mới nếu phát hiện lỗi phần cứng (Self-healing ở tầng hạ tầng).

### 4.2. Tầng Quản Lý Bản Đóng Gói: Amazon ECR
* **Thay vì đẩy image lên Docker Hub cá nhân bên ngoài**: Nhóm sử dụng **Amazon ECR** nội bộ trong cùng AWS Region.
* **Lợi thế kỹ thuật**:
  * Tốc độ kéo (pull) image về cụm EKS nhanh gấp 5 lần qua đường truyền nội mạng AWS Private Network.
  * Kích hoạt cơ chế **Image Scanning on Push**: Mỗi khi GitHub Actions đẩy image mới lên, ECR tự động quét và cảnh báo các lỗ hổng phần mềm trước khi cho phép triển khai.

### 4.3. Tầng Dữ Liệu Có Trạng Thái: Amazon RDS & Amazon S3
* **Cơ sở dữ liệu Amazon RDS PostgreSQL 16.3**:
  * Nằm trong **DB Subnet Group** trải dài qua 2 Availability Zones (`us-east-1a` và `us-east-1b`), được bảo vệ trong Private Subnet chỉ cho phép kết nối từ EKS Security Group qua cổng 5432.
  * **Automated Daily Backups & Point-in-Time Recovery (PITR)**: Sao lưu liên tục từng giây, bảo vệ dữ liệu nghiệp vụ tuyệt đối an toàn.
  * **Storage Auto-scaling**: Tự động mở rộng từ 20 GB lên 50 GB khi lượng task/dự án tăng trưởng.
* **Lưu trữ đối tượng Amazon S3**:
  * Lưu trữ bền vững tài liệu, avatar với độ bền **99.999999999% (11 số 9)**.
  * Không làm tiêu hao ổ cứng máy ảo K8s, cho phép phân phối file trực tiếp qua Pre-signed URLs và hỗ trợ CORS đầy đủ cho frontend.

### 4.4. Tầng Bảo Mật & Quản Lý Bí Mật: AWS Secrets Manager
* Mật khẩu quản trị database và các khóa mã hóa Django Session không bị hard-code trong file cấu hình hay Git.
* Tất cả được lưu trữ tại **AWS Secrets Manager**, tự động mã hóa bằng **AWS KMS (Key Management Service)** và được cấp phát cho Pod khi khởi động.

### 4.5. Cơ chế Cân Bằng Tải & Co Giãn Tự Động (Auto-scaling)
* **Cân bằng tải Layer 7 thông minh**: **AWS Application Load Balancer (ALB)** tiếp nhận lưu lượng từ người dùng và tự động định tuyến đến các nhóm Pod tương ứng theo URL path (`/`, `/api`, `/live`).
* **Co giãn Pod tự động (Horizontal Pod Autoscaler - HPA)**:
  * Thu thập dữ liệu tài nguyên thông qua `metrics-server`.
  * Tự động điều chỉnh số lượng bản sao từ **2 đến 5 Pods** cho cả `plane-frontend` và `plane-api` khi mức tiêu thụ CPU vượt 70% hoặc RAM vượt 80%, đảm bảo hệ thống phản ứng tức thì khi có đột biến truy cập.

---

## 5. QUY TRÌNH GITOPS KHÉP KÍN (CI/CD)

Hệ thống vận hành theo chu trình tự động hóa khép kín:

$$\text{Developer} \xrightarrow{\text{git push}} \text{GitHub Actions CI} \xrightarrow{\text{Lint + Trivy}} \text{Push Amazon ECR} \xrightarrow{\text{Update Tag}} \text{ArgoCD (in EKS)} \xrightarrow{\text{Pull-based Sync}} \text{EKS Pods (Zero Downtime)}$$

1. **Continuous Integration (CI) với GitHub Actions**:
   * Khi có commit vào nhánh `main`, pipeline tự động chạy kiểm tra chất lượng mã nguồn Python (`apps/api`), kích hoạt công cụ **Trivy** quét mã độc, đóng gói Docker Image và đẩy trực tiếp lên **Amazon ECR**.
   * Sau khi push thành công, GitHub Actions tự động cập nhật Image Tag mới vào thư mục manifests `k8s/` của kho GitOps.
2. **Continuous Delivery (CD) với ArgoCD**:
   * ArgoCD Controller thường trực trong cụm EKS tự động phát hiện thay đổi trên GitOps repo.
   * Tiến hành kéo cấu hình về và áp dụng xuống cụm (`Auto-Sync`) theo chiến lược **Rolling Update** (không gián đoạn dịch vụ).
   * Kích hoạt cơ chế **Self-Healing**: Mọi hành vi sửa đổi thủ công trên cụm đều tự động bị ghi đè về đúng trạng thái khai báo trong Git.

