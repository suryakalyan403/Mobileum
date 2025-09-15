pipeline {
    agent any

    stages {
        stage('K8s Access') {
            steps {
                withCredentials([file(credentialsId: 'kube-config', variable: 'KUBECONFIG')]) {
                    sh 'echo $KUBECONFIG'
                    sh 'cat $KUBECONFIG | head -n 5'
                }
            }
        }
    }
}

