# PyCon Korea API Server (2024 ~)

## 1. 로컬 개발 환경 설정
본 프로젝트는 Python3.11 (또는 이후 버전)과 Poetry를 사용합니다.
- Poetry 설치는 [여기](https://python-poetry.org/docs/)에서 확인해주세요.

### 1.1. 프로젝트 설치
```bash
poetry install
```

### 1.2. pre-commit hook 설정
본 프로젝트에서는 코딩 컨벤션을 준수하기 위해 [pre-commit](https://pre-commit.com/)을 사용합니다.  
pre-commit을 설치하려면 다음을 참고해주세요.

#### 1.2.1. Linux / macOS
```bash
# 설치
make hooks-install

# 프로젝트 전체 코드 lint 검사 & format
make lint

# 프로젝트 전체 코드에 대해 mypy 타입 검사
make mypy
```

#### 1.2.2. Windows
```bash
# 설치
poetry run pre-commit install

# 프로젝트 전체 코드 lint 검사 & format
poetry run pre-commit run --all-files

# 프로젝트 전체 코드에 대해 mypy 타입 검사
poetry run pre-commit run mypy --all-files
```
