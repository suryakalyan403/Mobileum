pipeline {
  agent any
  environment {
    KUBECONFIG = credentials('k8s-jenkins-secret-kubeconfig')
  }
  stages {
    stage('Check Cluster Access') {
      steps {
        sh 'kubectl cluster-info'
        sh 'kubectl get nodes'
        sh 'kubectl get pods -A'
      }
    }
  }
}

