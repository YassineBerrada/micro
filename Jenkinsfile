def COLOR_MAP = [
    'SUCCESS': 'good',
    'FAILURE': 'danger',
    'UNSTABLE': 'warning'
]

pipeline {
    agent any

    tools {
        maven "MAVEN3.9"
        jdk "JDK17"
    }

    environment {
        IMAGE_TAG = "${BUILD_ID}-${new Date().format('dd-MM-HH-mm')}"
        NEXUS_DOCKER_REPO = " 34.238.246.157:8082"
        DOCKER_USER = "admin"
        DOCKER_PASS = "YassineNexus12**"
    }

    stages {
        stage('Build all microservices') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    def services = ['configservice', 'counterservice', 'gatewayservice', 'registryservice']
                    for (svc in services) {
                        echo "Processing ${svc}"
                        sh """
                            cd ${svc}
                            docker build -t ${NEXUS_DOCKER_REPO}/${svc}:${IMAGE_TAG} .
                            docker tag ${NEXUS_DOCKER_REPO}/${svc}:${IMAGE_TAG} ${NEXUS_DOCKER_REPO}/${svc}:latest
                            echo "${DOCKER_PASS}" | docker login ${NEXUS_DOCKER_REPO} -u ${DOCKER_USER} --password-stdin
                            docker push ${NEXUS_DOCKER_REPO}/${svc}:${IMAGE_TAG}
                            docker push ${NEXUS_DOCKER_REPO}/${svc}:latest
                            docker logout ${NEXUS_DOCKER_REPO}
                            cd ..
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline completed with status: ${currentBuild.currentResult}"
        }
    }
}
