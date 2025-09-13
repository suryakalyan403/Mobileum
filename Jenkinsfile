pipeline {
    agent any


    stages {
        stage('Docker Registry Login') {
            steps {
                script {
                   
                    echo "***** Testing the Pipeline **********"
                    sh '''
                       whoami
                       curl -sLX POST "$MOB_REG_URL/auth?f=skopeo" \
                       -d "id=$MDS_ID&secret=$MDS_SECRET" | sh 
                     '''

                }
            }
        }
    }
}

