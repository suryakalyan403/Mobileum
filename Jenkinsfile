pipeline {
    agent any

    stages {
        stage('Docker Registry Login') {
            steps {
                script {
                    echo "***** Authenticating to r.raid.cloud **********"
                    sh '''
                        export XDG_RUNTIME_DIR=/tmp/containers
                        mkdir -p $XDG_RUNTIME_DIR
                         
                        LOGIN_CMD=$(curl -sLX POST "$MOB_REG_URL/auth?f=docker" \
                          -d "id=$MDS_ID&secret=$MDS_SECRET")
                   
                        echo "Running: $LOGIN_CMD"
                        eval "$LOGIN_CMD"
                    '''
                }
            }
        }

        stage('Pull Image from Remote Registry') {
            steps {
                echo "********* Pulling the Image *********"
                sh '''
                    docker pull $DOC_REG/$DOC_IMG:$IMG_TAG
                '''
            }
        }

        stage('Tag Image') {
            steps {
                echo "********* Tagging the Image *********"
                sh '''
                    docker tag $DOC_REG/$DOC_IMG:$IMG_TAG \
                        $DOC_IMG/$DOC_IMG:$IMG_TAG
                '''
            }
        }

        stage('Push Image to Local Registry') {
            steps {
                echo "********* Pushing Image to the Registry *********"
                sh '''
                    docker push $DOC_IMG/$DOC_IMG:$IMG_TAG
                '''
            }
        }
    }
}



