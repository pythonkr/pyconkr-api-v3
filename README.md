# PyCon Korea API Server (2024 ~)

## 로컬 개발 환경 설정
본 프로젝트는 Python3.11 (또는 이후 버전)과 Poetry를 사용합니다.
- Poetry 설치는 [여기](https://python-poetry.org/docs/)에서 확인해주세요.

### 로컬 인프라 구성
#### Docker
```bash
docker-compose --env-file .env.local -f ./infra/docker-compose.dev.yaml up -d
```
만약 `make`를 사용하실 수 있다면 아래와 같이 사용하실 수 있습니다.
```bash
make docker-compose-up   # MySQL 컨테이너 시작
make docker-compose-down # MySQL 컨테이너 종료
make docker-compose-rm   # MySQL 컨테이너 삭제
```

### pre-commit hook 설정
본 프로젝트에서는 코딩 컨벤션을 준수하기 위해 [pre-commit](https://pre-commit.com/)을 사용합니다.  
pre-commit을 설치하려면 다음을 참고해주세요.

#### Linux / macOS
```bash
# 설치
make hooks-install

# 프로젝트 전체 코드 lint 검사 & format
make lint

# 프로젝트 전체 코드에 대해 mypy 타입 검사
make mypy
```

#### Windows
```powershell
# 설치
poetry run pre-commit install

# 프로젝트 전체 코드 lint 검사 & format
poetry run pre-commit run --all-files

# 프로젝트 전체 코드에 대해 mypy 타입 검사
poetry run pre-commit run mypy --all-files
```

### 프로젝트 설치
```bash
poetry install
```

## Run
아래 명령어로 서버를 실행할 수 있습니다. `.env.local` 파일이 있는 경우, 해당 파일을 자동으로 사용합니다.
```bash
python manage.py runserver 0.0.0.0:48000
```
만약 .env 파일 경로를 별도로 지정하고 싶다면 아래와 같이 실행할 수 있습니다.
```bash
ENV_PATH='<dotenv 파일 경로>' python manage.py runserver
```

추가로 `make`를 사용하실 수 있다면, 아래와 같이 실행 시 `.env.local` 파일을 사용합니다.  
`.env.local` 파일은 기본적으로 MySQL 컨테이너를 바라보도록 설정되어 있습니다.
```bash
make local-api
```
