# CẤU TRÚC TRIỂN KHAI KUBERNETES GITOPS CHO PLANE

Thư mục này chứa toàn bộ các khai báo tài nguyên Kubernetes (Manifests) của nền tảng quản trị dự án **Plane**, được thiết kế theo chuẩn **Cloud-Native & GitOps**.

---

## 1. NGUYÊN TẮC THIẾT KẾ KIẾN TRÚC

Hệ thống tuân thủ triệt để nguyên tắc **phân tách Stateless và Stateful (Decoupled Architecture)**:

```
+-------------------------------------------------------------------------+
|                       KUBERNETES CLUSTER (STATELESS)                    |
|                                                                         |
|  [ Traefik Ingress Controller ]                                         |
|         │                                                               |
|         ├───> /       ──> [ plane-frontend (Next.js) ] (HPA: 2-5 pods)  |
|         ├───> /api    ──> [ plane-api (Django) ]      (HPA: 2-5 pods)  |
|         └───> /live   ──> [ plane-live (WebSocket) ]                    |
|                                 │                                       |
|  [ plane-worker ] (Celery) <────┴───> [ plane-redis (Cache & Broker) ]  |
|  [ plane-beat ]   (Scheduler)                                           |
|  [ plane-migrator ] (Job)                                               |
+-------------------------------------------------------------------------+
               │                                      │
               ▼ (SQL Queries)                        ▼ (Object Storage API)
+───────────────────────────────+      +──────────────────────────────────+
|     AWS RDS POSTGRESQL        |      |          AWS S3 BUCKET           |
| (Multi-AZ, Auto Backups PITR) |      | (Dung lượng vô hạn, bền 11 số 9) |
+───────────────────────────────+      +──────────────────────────────────+
```

* **Tầng Tính toán (Stateless - Trong K8s)**:
  * `plane-frontend`: Giao diện người dùng Next.js.
  * `plane-api`: Xử lý nghiệp vụ chính Django REST Framework.
  * `plane-live`: Kết nối WebSocket cho tính năng cộng tác thời gian thực.
  * `plane-worker`: Xử lý tác vụ bất đồng bộ (Celery Worker).
  * `plane-beat`: Định thời tác vụ định kỳ (Celery Beat).
  * `plane-migrator`: Tự động áp dụng migrate database khi triển khai.
  * `plane-redis`: Cache phiên làm việc và hàng đợi Celery.
* **Tầng Dữ liệu (Stateful - Ngoài K8s / AWS PaaS)**:
  * **AWS RDS PostgreSQL**: Lưu trữ dữ liệu quan hệ (Người dùng, Dự án, Task, Issue).
  * **AWS S3 Bucket**: Lưu trữ tệp đính kèm, hình ảnh tài nguyên.

---

## 2. CẤU TRÚC THƯ MỤC MANIFESTS

```text
k8s/
├── 00-namespace.yaml          # Khởi tạo Namespace 'plane'
├── 01-configs/
│   ├── configmap.yaml         # Biến môi trường hệ thống (S3, Redis, URLs)
│   └── secret.yaml            # Khóa bí mật và chuỗi kết nối AWS RDS
├── 02-broker/
│   └── redis.yaml             # Redis Deployment & Service (In-memory)
├── 03-services/
│   ├── plane-migrator.yaml    # Kubernetes Job migrate DB
│   ├── plane-api.yaml         # Backend Deployment & Service
│   ├── plane-frontend.yaml    # Frontend Deployment & Service
│   ├── plane-live.yaml        # Realtime WebSocket Deployment & Service
│   ├── plane-worker.yaml      # Celery Worker Deployment
│   └── plane-beat.yaml        # Celery Beat Deployment
├── 04-ingress/
│   └── ingress.yaml           # Traefik Ingress định tuyến lưu lượng
├── 05-scaling/
│   └── hpa.yaml               # HorizontalPodAutoscaler cho Web và API
└── 99-argocd/
    └── application.yaml       # ArgoCD GitOps Application tự động đồng bộ
```

---

## 3. TRIỂN KHAI VÀ VẬN HÀNH

### Triển khai thủ công qua `kubectl`:
```bash
# Áp dụng theo thứ tự chuẩn
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-configs/
kubectl apply -f 02-broker/
kubectl apply -f 03-services/
kubectl apply -f 04-ingress/
kubectl apply -f 05-scaling/
```

### Triển khai tự động bằng GitOps (ArgoCD):
Chỉ cần áp dụng file ArgoCD Application:
```bash
kubectl apply -f 99-argocd/application.yaml
```
ArgoCD sẽ tự động lắng nghe nhánh `main` của repository và đồng bộ trạng thái mong muốn (Desired State) xuống cụm Kubernetes.
