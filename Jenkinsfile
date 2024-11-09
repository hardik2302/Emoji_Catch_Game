pipeline {
    agent any

    environment {
        IMAGE_NAME = "hardikagrawal2320/emoji-game"
        VERSION_TAG = "${BUILD_NUMBER}" // Use Jenkins build number as version tag
         
    }

    stages {
        stage('Git Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/hardik2302/Emoji_Catch_Game']])
            }
        }
        stage('Install Dependencies') {
            steps {
                sh 'npm install'  // Install dependencies (including Jest and NYC)
            }
        }
        stage('Run Tests and Generate Coverage') {
            steps {
                sh 'npm test'  // Run tests and generate coverage report
            }
        }
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner';
                    withCredentials([string(credentialsId: 'emoji_game', variable: 'emoji_game')]) {
                        withSonarQubeEnv() {
                            // Run SonarScanner for the first project
                            sh """
                                ${scannerHome}/bin/sonar-scanner \
                                    -Dsonar.projectKey=emoji_game \
                                    -Dsonar.sources=. \
                                    -Dsonar.host.url="http://192.168.56.101:9000" \
                                    -Dsonar.token=${emoji_game}
                                    -Dsonar.javascript.lcov.reportPaths=coverage/lcov-report/index.html
                            """
                        }
                    }
                }
            }
        }
        // stage('Quality Gate') {
        //     steps {
        //         script {
        //             timeout(time: 1, unit: 'MINUTES') {
        //                 waitForQualityGate abortPipeline: true
        //             }
        //         }
        //     }
        // }
        stage('Docker build') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh "docker build -t ${IMAGE_NAME}:${VERSION_TAG} ."
                    }
                }
            }
        }
        stage('Docker Push Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh "docker push ${IMAGE_NAME}:${VERSION_TAG}"
                        // Also push the image with 'latest' tag
                        sh "docker tag ${IMAGE_NAME}:${VERSION_TAG} ${IMAGE_NAME}:latest"
                        sh "docker push ${IMAGE_NAME}:latest"
                    }
                }
            }
        }
    }
}
