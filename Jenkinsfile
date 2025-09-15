pipeline {
    agent any
    stages {
        stage('Test K8s Secret') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh 'echo $KUBECONFIG'
                }
            }
        }
    }
}

