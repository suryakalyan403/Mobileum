pipeline {
    agent any
    stages {
        stage('K8s Access') {
            steps {
                withCredentials([file(credentialsId: 'kube-config', variable: 'KUBECONFIG')]) {
                    sh '''
                        kubectl cluster-info
                        kubectl get nodes
                    '''
                }
            }
        }
    }
}

