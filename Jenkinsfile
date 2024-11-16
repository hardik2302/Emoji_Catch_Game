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
        // stage('Install Dependencies') {
        //     steps {
        //         sh 'npm install'  // Install dependencies (including Jest and NYC)
        //     }
        // }
        // stage('Run Tests and Generate Coverage') {
        //     steps {
        //         sh 'npm test'  // Run tests and generate coverage report
        //     }
        // }
        stage('SonarQube Analysis') {
        //     steps {
        //         script {
        //             def scannerHome = tool 'SonarScanner';
        //             withCredentials([string(credentialsId: 'emoji_game', variable: 'emoji_game')]) {
        //                 withSonarQubeEnv() {
        //                     // Run SonarScanner for the first project
        //                     sh """
        //                         ${scannerHome}/bin/sonar-scanner \
        //                             -Dsonar.projectKey=emoji_game \
        //                             -Dsonar.sources=. \
        //                             -Dsonar.host.url="http://192.168.56.101:9000" \
        //                             -Dsonar.token=${emoji_game}
        //                     """
        //                 }
        //             }
        //         }
        //     }
        // }
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
                        // Also push the image with 'blue' or 'green' tag
                        sh "docker tag ${IMAGE_NAME}:${VERSION_TAG} ${IMAGE_NAME}:${TAG}"
                        sh "docker push ${IMAGE_NAME}:${TAG}"
                    }
                }
            }
        }
        // stage('Deploy to Kubernetes') {
        //     steps {
        //         script {
        //             def deploymentFile = ""
        //             if (params.DEPLOY_ENV == 'blue') {
        //                 deploymentFile = 'app-deployment-blue.yml'
        //             } else {
        //                 deploymentFile = 'app-deployment-green.yml'
        //             }

        //             withKubeConfig(caCertificate: '', clusterName: 'devopsshack-cluster', contextName: '', credentialsId: 'k8-token', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://46743932FDE6B34C74566F392E30CABA.gr7.ap-south-1.eks.amazonaws.com') {
        //                 sh "kubectl apply -f ${deploymentFile} -n ${KUBE_NAMESPACE}"
        //             }
        //         }
        //     }
        // }
    }
}
