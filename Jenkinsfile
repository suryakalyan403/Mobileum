pipeline {
    agent any
    stages {
        stage('Test K8s Secret') {
            steps {
                withCredentials([file(credentialsId: 'kube-config', variable: 'KUBECONFIG')]) {
                    sh 'echo $KUBECONFIG'
                }
            }
        }
    }
}

