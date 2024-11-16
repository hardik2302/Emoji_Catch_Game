pipeline {
    agent any

    parameters {
        choice(name: 'DEPLOY_ENV', choices: ['blue', 'green'], description: 'Choose which environment to deploy: Blue or Green')
        choice(name: 'DOCKER_TAG', choices: ['blue', 'green'], description: 'Choose the Docker image tag for the deployment')
        booleanParam(name: 'SWITCH_TRAFFIC', defaultValue: false, description: 'Switch traffic between Blue and Green')
    }
    
    environment {
        IMAGE_NAME = "hardikagrawal2320/emoji-game"
        VERSION_TAG = "${BUILD_NUMBER}" // Use Jenkins build number as version tag      
        TAG = "${params.DOCKER_TAG}"  // The image tag now comes from the parameter
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
                            """
                        }
                    }
                }
            }
        }
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
                        // Also push the image with 'blue' or 'green' tag
                        sh "docker tag ${IMAGE_NAME}:${VERSION_TAG} ${IMAGE_NAME}:${TAG}"
                        sh "docker push ${IMAGE_NAME}:${TAG}"
                    }
                }
            }
        }
        stage('Deploy Service') {
            steps {
                script {
                    // Apply the service YAML file to ensure the service exists
                    sh "kubectl apply -f emoji-service.yml"
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([string(credentialsId: 'kubeconfig', variable: 'KUBE_CONFIG')]) {
                    script {
                        def deploymentFile = params.DEPLOY_ENV == 'blue' ? 'app-deployment-blue.yml' : 'app-deployment-green.yml'
                        // Apply the selected environment's deployment YAML file
                        sh "kubectl apply -f ${deploymentFile}"
                    }
                }
            }
        }
        stage('Switch Traffic (if enabled)') {
            when {
                expression { params.SWITCH_TRAFFIC }
            }
            steps {
                withCredentials([string(credentialsId: 'kubeconfig', variable: 'KUBE_CONFIG')]) {
                    script {
                        // Update the service selector to point to the selected environment
                        sh """
                        kubectl patch service emoji-service -p '{\"spec\":{\"selector\":{\"app\":\"emoji\",\"version\":\"${params.DEPLOY_ENV}\"}}}'
                        """
                    }
                }
            }
        }
        stage('Scale Down Previous Deployment') {
            when {
                expression { params.SWITCH_TRAFFIC }
            }
            steps {
                withCredentials([string(credentialsId: 'kubeconfig', variable: 'KUBE_CONFIG')]) {
                    script {
                        // Scale down the opposite deployment (e.g., if blue is active, scale down green)
                        def oppositeEnv = (params.DEPLOY_ENV == 'blue') ? 'green' : 'blue'
                        sh "kubectl scale deployment emoji-${oppositeEnv} --replicas=0"
                    }
                }
            }
        }
    }
}
