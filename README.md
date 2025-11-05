# Personal service Infrastructure

이 저장소는 개인 서비스 운영을 위한 AWS 인프라를 [Terraform](https://www.terraform.io/)과 [Terragrunt](https://terragrunt.gruntwork.io/)를 사용하여 코드 형태로 관리합니다.

## Services

### morning-letter
<img src="assets/aws_architecture_diagram.svg" />

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

## Getting Started

**필수 조건:**

- AWS 계정
- [AWS IAM Identity Center](https://aws.amazon.com/iam/identity-center/) 설정 완료 및 사용자 생성
- [Terraform](https://developer.hashicorp.com/terraform/install) v1.0 이상 설치
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) 설치
- [AWS CLI](https://aws.amazon.com/cli/) 설치

**초기 환경 설정:**

1. **AWS CLI SSO 설정:** IAM Identity Center 사용자 정보를 사용하여 AWS CLI 프로필을 구성합니다. 터미널에서 다음 명령을 실행하고 안내에 따릅니다. (예: 프로필 이름을 `my-sso-profile`로 지정)
   ```bash
   aws configure sso --profile my-sso-profile
   ```
   _이후 모든 `terragrunt` 명령어 실행 전에 해당 프로필로 로그인(`aws sso login --profile my-sso-profile`)하거나 `AWS_PROFILE=my-sso-profile` 환경 변수를 설정해야 합니다._
2. **초기 권한 확인:** 최초 부트스트랩 작업을 위해 현재 SSO 프로필에 연결된 IAM 역할이 충분한 권한(예: `AdministratorAccess`)을 가지고 있는지 확인합니다. (이 권한은 이후 단계에서 조정됩니다.)

**부트스트랩 인프라 생성:**

1. **Terraform 백엔드 생성:** Terraform 상태 저장을 위한 S3 버킷(`infra-terraform-state-2025`) 및 DynamoDB 테이블(`infra-terraform-state-lock-2025`)을 생성합니다.
   ```bash
   # bootstrap/environments/prod/backend 디렉토리로 이동했다고 가정
   cd bootstrap/environments/prod/backend
   terragrunt apply
   ```
   _만약 해당 리소스가 이미 존재한다는 오류가 발생하면, 상태 파일과 실제 리소스를 동기화하기 위해 `terragrunt import` 명령을 사용해야 합니다. (자세한 내용은 오류 메시지 참조)_
2. **(선택 사항) EC2 키페어 생성:** 필요한 경우 EC2 접속용 키페어를 생성합니다. (프로세스 문서에는 명시되지 않았으므로, 필요에 따라 실행)
   ```bash
   # bootstrap/environments/prod/keypair 디렉토리로 이동했다고 가정
   cd ../keypair # 이전 단계에서의 상대 경로
   terragrunt apply
   ```

**필수 파일 업로드:**

- 애플리케이션 배포에 필요한 환경 변수 파일 (`.env.{environment}`), GitHub 토큰 파일 (`github_token_docker_registry.env`), CodeDeploy 배포 아티팩트 등을 미리 생성하여 지정된 S3 버킷 (`infra-files-2025`) 내의 경로에 업로드해야 합니다.
  - `.env.{environment}`: `s3://infra-files-2025/morning-letter-env/` 경로에 업로드 (애플리케이션 리포지토리의 스크립트 사용)
  - `github_token_docker_registry.env`: `s3://infra-files-2025/morning-letter-infra/deployments/` 경로에 업로드
  - CodeDeploy 아티팩트: `s3://infra-files-2025/morning-letter-infra/deployments/` 경로에 업로드 (`morning-letter/environments/{environment}/deployment/create-artifact.sh` 스크립트 사용)
  - _주의: 이 단계는 Terraform/Terragrunt 외부에서 수행되어야 하는 수동 작업입니다._

**IAM 권한 조정 및 최종 설정:**

1. **Identity Center 구성 적용:** Terraform으로 IAM Identity Center 그룹 및 권한 세트 할당 등을 관리합니다. 이 과정에서 최초 설정에 사용된 광범위한 권한이 제거될 수 있습니다.
   ```bash
   # bootstrap/environments/prod/identity-center 디렉토리로 이동했다고 가정
   cd ../identity-center # 이전 단계에서의 상대 경로
   # terragrunt.hcl 파일 내 inputs (instance_arn, identity_store_id 등) 값 확인/설정
   terragrunt apply
   ```
2. **SSO 재로그인:** IAM 권한 변경 후, 현재 터미널 세션의 자격 증명이 만료되거나 권한이 부족할 수 있습니다. 다시 로그인합니다.
   ```bash
   aws sso login --profile my-sso-profile
   ```
   _만약 `Required property 'sso_region' or 'sso_start_url' missing` 오류 발생 시, `~/.aws/config` 파일에서 해당 프로필의 `sso_session` 라인을 삭제하고 다시 로그인해 보세요._

**애플리케이션 환경 최초 배포:**

이 단계는 특정 서비스(예: `morning-letter`)의 특정 환경(예: `dev`)을 처음 배포할 때 필요합니다.

1. **초기 배포 플래그 설정:** CodeDeploy가 초기 Autoscaling Group을 인식하도록 플래그를 설정합니다.
   - `morning-letter/environments/dev/deployment/terragrunt.hcl` 파일을 열어 `inputs` 블록 내의 `init_asg_app` 값을 `true`로 설정합니다.
2. **환경 전체 배포:** 대상 환경 디렉토리에서 `run-all apply`를 실행하여 모든 종속 모듈(VPC, Role, Storage, ALB, Instance, Deployment 등)을 순서대로 배포합니다.
   ```bash
   cd morning-letter/environments/dev
   terragrunt run-all apply
   ```
3. **인스턴스 확인:** 배포된 EC2 인스턴스가 정상적으로 실행되고 있는지 확인합니다. (예: AWS 콘솔 확인, SSH 접속 테스트)
4. **초기 배포 플래그 해제:** 초기 배포가 완료되었으므로 플래그를 다시 `false`로 설정합니다.
   - `morning-letter/environments/dev/deployment/terragrunt.hcl` 파일에서 `init_asg_app` 값을 `false`로 변경합니다.
5. **배포 설정 업데이트:** 변경된 플래그 값을 CodeDeploy 배포 그룹에 반영합니다.
   ```bash
   cd morning-letter/environments/dev/deployment
   terragrunt apply
   ```

이제 애플리케이션 환경이 기본적인 배포 준비를 마쳤습니다.

## Usage (환경 배포 - 최초 이후)

최초 배포 이후 환경을 업데이트하거나 변경 사항을 적용할 때는 "애플리케이션 환경 최초 배포" 섹션의 1, 4, 5 단계를 제외하고 진행합니다.

**주의:** 각 환경의 리소스는 서로 의존성이 있을 수 있습니다. `run-all` 명령어를 사용하거나, 개별 적용 시 모듈 간 의존성을 고려하여 배포해야 합니다.

**예시: `dev` 환경 업데이트**

- **전체 동시 적용 (Terragrunt 의존성 활용):**

  ```bash
  cd morning-letter/environments/dev
  terragrunt run-all apply # 또는 plan
  ```

- **개별 모듈 적용 (순서 주의 - 예시):**
  ```bash
  # 필요한 모듈 디렉토리로 이동하여 terragrunt apply 실행
  cd morning-letter/environments/dev/vpc
  terragrunt apply
  cd ../role
  terragrunt apply
  # ... 기타 필요한 모듈 순차 적용 (storage, alb, instance, deploy) ...
  ```

**다른 환경 (stg, prd) 배포:**

`dev` 대신 해당 환경 디렉토리 (`morning-letter/environments/stg`, `morning-letter/environments/prd`)로 이동하여 동일한 명령어를 실행합니다.

**배포 후 작업:**

인프라 구성 후 실제 애플리케이션 코드 배포, 데이터베이스 마이그레이션, 최종 테스트 등은 별도의 프로세스(예: GitHub Actions, 애플리케이션 리포지토리 스크립트)를 통해 진행됩니다.

## 배포 전략: Blue/Green 배포

AWS CodeDeploy, ALB, Auto Scaling Group을 연동하여 다운타임을 최소화하는 Blue/Green 배포 전략을 사용합니다.

1. **평소 상태**: Blue ASG 인스턴스가 Blue TG를 통해 ALB로부터 트래픽을 받습니다. Green ASG는 배포 시 CodeDeploy에 의해 생성됩니다.
2. **배포 시작**:
   - Green ASG가 새 버전의 코드를 실행할 인스턴스를 시작하고 Green TG에 등록합니다.
   - ALB가 Green 인스턴스의 상태 확인을 시작합니다.
3. **CodeDeploy 실행**:
   - CodeDeploy는 Green ASG를 대상으로 새 애플리케이션 버전을 배포합니다.
   - 배포 후 훅을 통해 Green 환경의 안정성을 검증합니다.
4. **트래픽 전환**:
   - Green 인스턴스가 안정적이라고 판단되면, CodeDeploy는 ALB 리스너 규칙을 수정하여 트래픽을 Blue TG에서 Green TG로 전환합니다.
5. **배포 완료 및 정리**:
   - 배포 성공 후, 설정에 따라 이전 Blue 환경의 인스턴스(Blue ASG)를 종료합니다.

## 향후 개선 사항 / TODO

- [ ] HTTPS 리스너 활성화 및 ACM 인증서 적용 자동화
- [ ] CloudWatch 경보 설정 및 모니터링 대시보드 구성
