# Morning Letter Infrastructure

이 저장소는 "Morning Letter" 서비스 운영을 위한 AWS 인프라를 [Terraform](https://www.terraform.io/)과 [Terragrunt](https://terragrunt.gruntwork.io/)를 사용하여 코드 형태로 관리합니다.

## 기술 스택

- **클라우드 제공자:** [AWS (Amazon Web Services)](https://aws.amazon.com/)
- **IaC (Infrastructure as Code):** [Terraform](https://www.terraform.io/), [Terragrunt](https://terragrunt.gruntwork.io/)
- **주요 AWS 서비스:**
  - [VPC (Virtual Private Cloud)](https://aws.amazon.com/vpc/): 네트워크 격리
  - [IAM (Identity and Access Management)](https://aws.amazon.com/iam/): AWS 리소스 접근 권한 관리
  - [Application Load Balancer (ALB)](https://aws.amazon.com/elasticloadbalancing/application-load-balancer/): 트래픽 분산 및 라우팅
  - [Auto Scaling Group (ASG)](https://aws.amazon.com/ec2/autoscaling/): 인스턴스 자동 확장 및 관리
  - [EC2 (Elastic Compute Cloud)](https://aws.amazon.com/ec2/): 애플리케이션 서버
  - [CodeDeploy](https://aws.amazon.com/codedeploy/): 자동화된 애플리케이션 배포
  - [S3 (Simple Storage Service)](https://aws.amazon.com/s3/): 이미지, 로그 등 객체 스토리지
  - [DynamoDB](https://aws.amazon.com/dynamodb/): 구독 정보 저장을 위한 NoSQL 데이터베이스
  - [RDS (Relational Database Service)](https://aws.amazon.com/rds/): 관계형 데이터베이스

## 주요 특징 및 기법

- **Infrastructure as Code (IaC):** [Terraform](https://www.terraform.io/)과 [Terragrunt](https://terragrunt.gruntwork.io/)를 활용하여 AWS 인프라를 선언적으로 관리합니다. 이를 통해 인프라 구성의 일관성, 재현성, 버전 관리를 보장합니다.
- **모듈화된 구조:** 재사용 가능한 [Terraform 모듈](./modules/)을 통해 VPC, ALB, 인스턴스 등 인프라 구성 요소를 표준화하고 코드 중복을 최소화합니다.
- **환경 분리:** [Terragrunt](./environments/)를 사용하여 개발(dev), 스테이징(stg), 운영(prd) 등 여러 환경의 구성을 효율적으로 관리하고, 각 환경별 차이점을 명확하게 정의합니다.
- **Blue/Green 배포 자동화:** [AWS CodeDeploy](./modules/deploy/), [ALB](./modules/alb/), [Auto Scaling Group](./modules/instance/)을 연동하여 애플리케이션 배포 시 다운타임을 최소화하는 Blue/Green 배포 파이프라인을 구축합니다.

## 프로젝트 구조

```
morning-letter/
├── bootstrap/       # 초기 설정 (Terraform Backend, Keypair 등)
├── environments/    # 환경별 (dev, stg, prd) Terragrunt 설정
│   ├── dev/
│   └── ... (stg, prd 등)
├── modules/         # 재사용 가능한 Terraform 모듈
│   ├── alb/
│   ├── backend/
│   ├── deploy/
│   ├── instance/
│   ├── role/
│   ├── storage/
│   └── vpc/
└── root.hcl         # Terragrunt 전역 설정 (루트에 위치 가정)
```

- [`bootstrap/`](./bootstrap/): Terraform 상태 관리를 위한 백엔드 설정 및 초기 키페어 생성 등 프로젝트 시작에 필요한 기본 구성을 포함합니다.
- [`environments/`](./environments/): 각 배포 환경(개발, 스테이징, 운영)에 대한 Terragrunt 구성 파일이 위치합니다. 환경별 변수와 모듈 호출을 정의합니다.
- [`modules/`](./modules/): VPC, ALB, EC2 인스턴스, 데이터베이스 등 재사용 가능한 인프라 구성 단위를 정의하는 Terraform 모듈들이 포함되어 있습니다.

## Get Started

**필수 조건:**

- AWS 계정 및 적절한 권한 설정
- [Terraform](https://developer.hashicorp.com/terraform/install) 설치
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) 설치
- AWS CLI 및 자격 증명 구성 ([AWS Configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html))

**초기 설정 (최초 1회):**

1.  Terraform 백엔드 설정:
    ```bash
    cd bootstrap/backend
    terragrunt apply
    ```
2.  EC2 키페어 생성:
    ```bash
    cd ../keypair
    terragrunt apply
    ```

## Usage (환경 배포)

**주의:** 각 환경의 리소스는 서로 의존성이 있을 수 있습니다. `run-all` 명령어를 사용하거나, 개별 적용 시 아래 제시된 순서 또는 모듈 간 의존성을 고려하여 배포해야 합니다.

**예시: `dev` 환경 배포**

- **전체 동시 적용 (Terragrunt 의존성 활용):**

  ```bash
  cd environments/dev
  terragrunt run-all apply
  ```

- **개별 모듈 적용 (순서 주의):**
  ```bash
  cd environments/dev/vpc
  terragrunt apply
  cd ../role
  terragrunt apply
  cd ../storage
  terragrunt apply
  cd ../alb
  terragrunt apply
  cd ../instance
  terragrunt apply
  cd ../deploy
  terragrunt apply
  ```

**다른 환경 (stg, prd) 배포:**

`dev` 대신 해당 환경 디렉토리로 이동하여 동일한 명령어를 실행합니다.

## 배포 전략: Blue/Green 배포

AWS CodeDeploy, ALB, Auto Scaling Group을 연동하여 다운타임을 최소화하는 Blue/Green 배포 전략을 사용합니다.

1.  **평소 상태**: Blue ASG 인스턴스가 Blue TG를 통해 ALB로부터 트래픽을 받습니다. Green ASG는 배포 시 CodeDeploy에 의해 생성됩니다.
2.  **배포 시작**:
    - Green ASG가 새 버전의 코드를 실행할 인스턴스를 시작하고 Green TG에 등록합니다.
    - ALB가 Green 인스턴스의 상태 확인을 시작합니다.
3.  **CodeDeploy 실행**:
    - CodeDeploy는 Green ASG를 대상으로 새 애플리케이션 버전을 배포합니다.
    - 배포 후 훅을 통해 Green 환경의 안정성을 검증합니다.
4.  **트래픽 전환**:
    - Green 인스턴스가 안정적이라고 판단되면, CodeDeploy는 ALB 리스너 규칙을 수정하여 트래픽을 Blue TG에서 Green TG로 전환합니다.
5.  **배포 완료 및 정리**:
    - 배포 성공 후, 설정에 따라 이전 Blue 환경의 인스턴스(Blue ASG)를 종료합니다.

## 향후 개선 사항 / TODO

- [ ] HTTPS 리스너 활성화 및 ACM 인증서 적용 자동화
- [ ] CloudWatch 경보 설정 및 모니터링 대시보드 구성
