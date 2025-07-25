# --- STAGE 1: Gradle을 이용해 Jar 파일 빌드 ---
# 프로젝트 빌드를 위해 Gradle과 JDK 17을 포함한 이미지를 기반으로 사용합니다.
FROM gradle:8.5.0-jdk17-focal AS builder

# 컨테이너 내부의 작업 폴더를 /app 으로 설정합니다.
WORKDIR /app

# ⭐️ 프로젝트 전체 파일을 컨테이너 안으로 복사합니다.
# 이렇게 하면 Dockerfile이 gradlew, settings.gradle 등 빌드에 필요한 모든 파일에 접근할 수 있습니다.
COPY . .

# ⭐️ Gradle 빌드를 실행하되, "-x test" 플래그로 불필요한 테스트는 건너뛰어 빌드 시간을 단축합니다.
RUN ./gradlew build -x test --no-daemon


# --- STAGE 2: 빌드된 Jar 파일로 최종 실행 이미지 생성 ---
# 실제 서비스 실행에는 JDK만 필요하므로, 훨씬 가벼운 openjdk 이미지 사용합니다.
FROM openjdk:17-jdk-slim

# 컨테이너 내부의 작업 폴더를 /app 으로 설정합니다.
WORKDIR /app

# ⭐️ builder 스테이지에서 빌드된 결과물(.jar 파일)만 정확한 경로에서 복사해옵니다.
COPY --from=builder /app/build/libs/*.jar app.jar

# 컨테이너가 시작될 때 "java -jar app.jar" 명령어로 애플리케이션을 실행합니다.
ENTRYPOINT ["java", "-jar", "app.jar"]