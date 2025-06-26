// Jenkinsfile pour pipeline Microservices
def COLOR_MAP = [
    'SUCCESS': 'good',
    'FAILURE': 'danger',
    'UNSTABLE': 'warning'
]

pipeline {
    agent any

    tools {
        maven "MAVEN3.9"
        jdk   "JDK17"
    }

    environment {
          NEXUS_DOCKER_REPO = "34.238.246.157:8082"
          DOCKER_USER       = "admin"
          DOCKER_PASS       = "YassineNexus12**"
    }


    stages {
        stage('Fetch code') {
            steps {
                    git branch: 'main', url: 'https://github.com/YassineBerrada/micro'
         }
        }


        stage('Build') {
            steps {
                // Compile sans tests
                sh 'mvn clean install -DskipTests'
            }
        }

        stage('Unit Tests') {
            steps {
                // Exécute les tests unitaires
                sh 'mvn test'
            }
        }

        stage('Checkstyle Analysis') {
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }

        stage('Sonar Code Analysis') {
            environment {
                scannerHome = tool 'sonar6.2'
            }
            steps {
                withSonarQubeEnv('sonarserver') {
                    // Utilise votre sonar-project.properties à la racine
                    sh "${scannerHome}/bin/sonar-scanner"
                }
            }
        }

        stage('Quality Gate') {
            steps {
                // Attend le résultat du Quality Gate et stoppe la pipeline en cas d'échec
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    // Récupère identifiants Nexus stockés dans Jenkins sous 'nexus-docker'
                    withCredentials([usernamePassword(
                        credentialsId: 'nexus-docker',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        // Génère un tag unique
                        def imageTag = "${env.BUILD_ID}-${new Date().format('ddMMyy-HHmm')}"
                        // Liste de vos microservices
                        def services = ['configservice', 'counterservice', 'gatewayservice', 'registryservice']
                        services.each { svc ->
                            dir(svc) {
                                // Connexion, build, tag & push
                                sh """
                                    echo "${DOCKER_PASS}" | docker login ${env.NEXUS_DOCKER_REPO} \
                                        -u ${DOCKER_USER} --password-stdin
                                    docker build -t ${env.NEXUS_DOCKER_REPO}/${svc}:${imageTag} .
                                    docker tag ${env.NEXUS_DOCKER_REPO}/${svc}:${imageTag} \
                                               ${env.NEXUS_DOCKER_REPO}/${svc}:latest
                                    docker push ${env.NEXUS_DOCKER_REPO}/${svc}:${imageTag}
                                    docker push ${env.NEXUS_DOCKER_REPO}/${svc}:latest
                                    docker logout ${env.NEXUS_DOCKER_REPO}
                                """
                            }
                        }
                    }
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                script {
                   // tag défini plus haut dans le stage Docker
                  def tag = "${env.BUILD_ID}-${new Date().format('ddMMyy-HHmm')}"
                  ansiblePlaybook(
                       playbook:  'ansible/deploy_docker.yml',
                       inventory: 'ansible/hosts.ini',
                       credentialsId: 'sonarqube3',
                       extraVars: [
                           image_tag: tag
                       ]
                  )
                }
             }
        }


    post {
        always {
            // Notification Slack identique à votre pipeline monolithique
            slackSend(
                channel: '#devopscicd',
                color:   COLOR_MAP[currentBuild.currentResult],
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}"
            )
        }
    }
}
