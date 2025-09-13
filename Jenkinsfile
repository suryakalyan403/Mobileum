pipeline {
    agent any


    stages {
        stage('Docker Registry Login') {
            steps {
                script {
                    sh '''whoami '''
                    echo "***** Testing the Pipeline **********"
                    sh '''
                       curl -sLX POST "$MOB_REG_URL/auth?f=skopeo" \
                       -d "id=$MDS_ID&secret=$MDS_SECRET" | sh 
                     '''

                }
            }
        }
    }
}

