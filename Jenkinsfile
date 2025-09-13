pipeline {
    agent any


    stages {
        stage('Docker Registry Login') {
            steps {
                script {
                    echo "***** Testing the Pipeline **********"
                    sh '''
                       export XDG_RUNTIME_DIR=/tmp/containers
                       mkdir -p $XDG_RUNTIME_DIR
                       curl -sLX POST "$MOB_REG_URL/auth?f=skopeo" \
                       -d "id=$MDS_ID&secret=$MDS_SECRET" | sh 
                     '''
                }
            }
        }
    }
}

