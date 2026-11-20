# 🚀 Nền Tảng Vận Hành Ứng Dụng Microservices Trên Kubernetes (Plane Platform)

> **Môn học**: NT114.R11 - Đồ án chuyên ngành (Học kỳ 1, Năm học 2026 - 2027)  
> **Tên đề tài**: Nghiên cứu và xây dựng nền tảng vận hành ứng dụng microservices trên Kubernetes  
> *(Building a Platform for Deploying and Operating Microservices on Kubernetes)*  
> **Giảng viên hướng dẫn**: ThS. Văn Thiên Luân  
> **Sinh viên thực hiện**:  
> 1. **Đào Đức Thịnh** - MSSV: 23521495 *(Chủ nhiệm đề tài)*  
> 2. **Nguyễn Bá Thiện** - MSSV: 23521480  
> **Repository**: [DucThinhIsMeX/plane-k8s-microservices-platform](https://github.com/DucThinhIsMeX/plane-k8s-microservices-platform)  

---

## 📖 1. Giới thiệu Đề tài
Đồ án tập trung nghiên cứu, thiết kế và triển khai một nền tảng vận hành vi dịch vụ hoàn chỉnh theo chuẩn **Cloud-Native & GitOps** trên hạ tầng **Amazon Web Services (AWS)** và **Kubernetes**.

Hệ thống ứng dụng thực nghiệm được lựa chọn là **Plane (`makeplane/plane`)** — nền tảng quản trị dự án và theo dõi tiến độ mã nguồn mở hiện đại hàng đầu thế giới (hơn 33.000 stars trên GitHub), được phát triển theo kiến trúc vi dịch vụ phân tán.

Hệ thống giải quyết 4 bài toán kỹ thuật cốt lõi:
1. **Tách biệt Stateless Compute và Stateful Datastores**: Toàn bộ vi dịch vụ ứng dụng chạy không lưu trạng thái trên Kubernetes (cho phép co giãn và tự phục hồi nhanh), trong khi tầng dữ liệu quan trọng được giao cho các dịch vụ nền tảng đám mây chuyên dụng (**AWS RDS PostgreSQL** và **AWS S3**).
2. **Khả năng sẵn sàng cao (High Availability)** và **Cân bằng tải nhiều lớp**: Kết hợp AWS Network Load Balancer (Layer 4) và Traefik Ingress Controller (Layer 7).
3. **Tự động co giãn theo tải (Horizontal Pod Autoscaler - HPA)**: Tự động điều chỉnh số lượng bản sao tính toán từ 2 đến 5 Pods dựa trên chỉ số CPU/Memory thực tế.
4. **Quy trình GitOps khép kín & DevSecOps**: Tự động hóa toàn diện từ lúc đẩy code lên GitHub, rà quét lỗ hổng bảo mật với **Trivy**, kiểm thử manifests, đến triển khai tự động qua **ArgoCD**.

---

## 🏛️ 2. Sơ đồ Kiến trúc Tổng thể (Master Architecture)

```
[ Khách hàng / Doanh nghiệp ]
              │ (HTTPS)
              ▼
[ AWS Network Load Balancer (NLB) ] (Public Zone - Port 80/443)
              │
              ▼
[ Traefik Ingress Controller ]
  ├──> Path: /      ──> [ plane-frontend (Next.js) ] (HPA: 2 - 5 Pods)
  ├──> Path: /api   ──> [ plane-api (Django REST) ]  (HPA: 2 - 5 Pods)
  └──> Path: /live  ──> [ plane-live (WebSocket) ]
              │
  [ plane-worker ] (Celery) <──── [ plane-redis (Cache & Queue) ]
  [ plane-beat ]   (Scheduler)
  [ plane-migrator ] (Job)
              │                                │
              ▼ (SQL Queries)                  ▼ (Object Storage API)
[ AWS RDS PostgreSQL 16.3 ]           [ AWS S3 Assets Bucket ]
(Multi-AZ, Auto Backups PITR)         (Độ bền 11 số 9, AES256, CORS)
```

---

## 🛠️ 3. Công nghệ Sử dụng trong Hệ thống

| Lớp kiến trúc | Công nghệ sử dụng |
| :--- | :--- |
| **Hạ tầng Đám mây (Cloud IaaS & PaaS)** | AWS VPC, EC2, NLB, **AWS RDS PostgreSQL 16.3**, **AWS S3** |
| **Hạ tầng dưới dạng mã (IaC)** | **Terraform** (quản lý 100% tài nguyên AWS), **Ansible** (bootstrap cụm K8s) |
| **Điều phối Container (Orchestration)** | **Kubernetes v1.31** (Calico CNI, Metrics-Server, Traefik Ingress) |
| **Quản trị Cụm Tập trung** | **Rancher Server Dashboard v2.x** |
| **Quy trình GitOps & DevSecOps** | **GitHub Actions** (CI), **Trivy** (Security Vulnerability Scan), **ArgoCD** (CD) |
| **Ứng dụng Microservices (Plane)** | Next.js (Web/Admin), Django REST (API), Node.js (Live WS), Celery, Redis |

---

## 📁 4. Cấu trúc Thư mục Dự án

```text
├── apps/                         # Mã nguồn vi dịch vụ Plane (api, web, live, space, admin)
├── IAC/                          # Toàn bộ mã nguồn Hạ tầng dưới dạng mã
│   ├── infra/
│   │   ├── envs/dev/             # Môi trường phát triển Terraform (main, variables, outputs)
│   │   └── modules/              # Các module: rds, s3-plane, network, security, edge, nlb, k8s-nodes
│   └── playbooks/                # Ansible Playbooks cấu hình cụm K8s và Rancher agent
├── k8s/                          # Khai báo Kubernetes Manifests chuẩn GitOps
│   ├── 00-namespace.yaml         # Khởi tạo namespace 'plane'
│   ├── 01-configs/               # ConfigMap & Secret kết nối AWS RDS và S3
│   ├── 02-broker/                # Redis in-memory cache & Celery message queue
│   ├── 03-services/              # Deployments: api, frontend, live, worker, beat, migrator
│   ├── 04-ingress/               # Traefik Ingress Layer 7 path routing
│   ├── 05-scaling/               # HorizontalPodAutoscaler (HPA) tự động co giãn
│   └── 99-argocd/                # Khai báo ArgoCD GitOps Application tự động đồng bộ
├── .github/workflows/ci-cd.yml   # Pipeline CI/CD: Linting, Trivy scan, K8s validation
└── BAO_CAO_TIEP_THU_Y_KIEN_VA_KE_HOACH_DO_AN.md # Bản thuyết minh kiến trúc chi tiết
```

---

## 🚀 5. Hướng dẫn Khởi chạy Nhanh

### 5.1. Cấp phát Hạ tầng AWS bằng Terraform
```bash
cd IAC/infra/envs/dev
terraform init
terraform plan
terraform apply -auto-approve
```

### 5.2. Cấu hình Cụm Kubernetes qua Ansible
```bash
# Đăng nhập vào Edge Bastion Node
ssh -F generated/ssh_config edge-bastion

# Chạy playbook cài đặt K8s 1.31 và Ingress
ansible-playbook -i generated/inventory.ini playbooks/site.yml
```

### 5.3. Triển khai Ứng dụng bằng GitOps (ArgoCD)
```bash
# Áp dụng khai báo ứng dụng ArgoCD
kubectl apply -f k8s/99-argocd/application.yaml
```
ArgoCD sẽ tự động kéo các cấu hình từ repository và đồng bộ xuống cụm Kubernetes.
