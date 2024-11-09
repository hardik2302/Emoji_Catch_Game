pipeline {
    agent any

    environment {
        SONARQUBE = 'sonarqube' // SonarQube server configured in Jenkins
        SONAR_TOKEN = credentials('SonarQube-Secret') // SonarQube token from Jenkins credentials
        SONAR_PROJECT_KEY = 'emoji_game' // Set the project key for SonarQube
        IMAGE_NAME = "hardikagrawal2320/emoji-game"
        VERSION_TAG = "${BUILD_NUMBER}" // Use Jenkins build number as version tag
    }

    stages {
        stage('Git Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/hardik2302/Emoji_Catch_Game']])
            }
        }
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner' // SonarQube Scanner tool installed in Jenkins
                    withSonarQubeEnv(SONARQUBE) {
                        sh "${scannerHome}/bin/sonar-scanner " +
                           "-Dsonar.projectKey=${SONAR_PROJECT_KEY} " +
                           "-Dsonar.projectName='Emoji Catch Game' " +
                           "-Dsonar.sources=. " +
                           "-Dsonar.host.url=$SONARQUBE_URL " +
                           "-Dsonar.login=$SONAR_TOKEN"
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
                    }
                }
            }
        }
    }
}
