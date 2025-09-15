pipeline {
    agent any

    parameters {
        choice(choices: ['all', 'portal', 't80'], description: 'Select microservices to deploy', name: 'MICROSERVICE')
        booleanParam(defaultValue: false, description: 'Dry run mode', name: 'DRY_RUN')
        booleanParam(defaultValue: false, description: 'Skip Tests', name: 'SKIP_TESTS')
    }
    
    environment {
        DEPLOYMENT_DIR = "${WORKSPACE}/src/bin"
        MICROSERVICES = "portal t80 t50 t52 t54 t55 t56"
        TERM = "xterm" 
    }

    stages {
        stage('Cluster Jenkins Connection Test') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                        export KUBECONFIG=$KUBECONFIG
                        echo "Kubeconfig file: $KUBECONFIG"
                        kubectl cluster-info
                        kubectl get nodes
                        kubectl get pods -A | head -20
                    '''
                }
            }
        }

        stage('Pre-deployment Checks') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                        sh '''
                            export KUBECONFIG=$KUBECONFIG
                            # Check cluster connectivity
                            kubectl cluster-info
                            # Check storage availability
                            kubectl get pvc -A
                        '''
                    }
                }
            }
        }
        
        stage('Deploy Services') {
            steps {
                script {
                    def servicesToDeploy = params.MICROSERVICE == 'all' ? env.MICROSERVICES.split() : [params.MICROSERVICE]
                    def dryRunFlag = params.DRY_RUN ? "dry-run" : ""
                    
                    servicesToDeploy.each { service ->
                        stage("Deploy ${service}") {
                            try {
                                sh """
                                    cd ${env.DEPLOYMENT_DIR}
                                    TERM=xterm  bash risk-man.sh install ${service} ${dryRunFlag}
                                """
                                
                                if (!params.DRY_RUN) {
                                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                                        timeout(time: 10, unit: 'MINUTES') {
                                            sh """
                                                export KUBECONFIG=$KUBECONFIG
                                                kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=${service} -n raid-rafm-${service} --timeout=300s
                                            """
                                        }
                                    }
                                }
                            } catch (Exception e) {
                                error "Failed to deploy ${service}: ${e.getMessage()}"
                            }
                        }
                    }
                }
            }
        }
        
        stage('Integration Tests') {
            when {
                expression { return !params.DRY_RUN && !params.SKIP_TESTS }
            }
            steps {
                script {
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                        sh '''
                            export KUBECONFIG=$KUBECONFIG
                            echo "Running integration tests..."
                            # Add your test commands here
                            kubectl get pods -A -l app.kubernetes.io/instance
                        '''
                    }
                }
            }
        }
        
        stage('Update Documentation') {
            when {
                expression { return !params.DRY_RUN }
            }
            steps {
                script {
                    // Update deployment documentation
                    sh '''
                        echo "Updating deployment documentation..."
                        date +%Y-%m-%d_%H-%M-%S > ${DEPLOYMENT_DIR}/last_deployment.txt
                    '''
                }
            }
        }
    }
    
    post {
        success {
            slackSend channel: '#deployments', 
                     message: "🚀 Successful deployment: ${params.MICROSERVICE} - ${env.BUILD_URL}"
        }
        failure {
            slackSend channel: '#deployments', 
                     message: "💥 Failed deployment: ${params.MICROSERVICE} - ${env.BUILD_URL}"
            // Send logs for debugging
            archiveArtifacts artifacts: '**/*.log', allowEmptyArchive: true
        }
        always {
            // Cleanup and generate report
            junit '**/test-results/*.xml'
            cleanWs()
        }
    }
}
