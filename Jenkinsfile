pipeline {
    agent any

    environment {
        KUBECONFIG = ''   // will be injected by withCredentials
    }

    stages {
        stage('Check Cluster Info') {
            steps {
                withCredentials([file(credentialsId: 'k8s-config', variable: 'KUBECONFIG')]) {
                    sh '''
                        echo "Using kubeconfig: $KUBECONFIG"
                        kubectl cluster-info
                        kubectl get nodes
                    '''
                }
            }
        }
    }
}

