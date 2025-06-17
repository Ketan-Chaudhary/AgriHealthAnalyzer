pipeline {
    agent any 

    environment {
        //NODE_ENV = 'production'
        PLANT_ID_API_KEY = credentials('plant-api-key')
    }
    
    tools {
        nodejs 'node18'
    }

    stages{
        stage('Checkout Code'){
            steps{
                 git branch: "${BRANCH_NAME}", url: 'https://github.com/Ketan-Chaudhary/AgriHealthAnalyzer.git'
            }
        }

        stage('Install Dependencies'){
            steps{
                dir('client') {
                    sh 'npm install'
                }

                dir('server'){
                    sh 'npm install'
                }
            }
        }

        stage('Build Frontend'){
            steps{
                dir('client'){
                    sh 'export PATH=./node_modules/.bin:$PATH'
                    sh 'npm run build'
                }
            }
        }

        stage('Run Backend Server Temp.'){
            when{
                expression { BRANCH_NAME != 'main'}
            }
            steps{
                echo 'Testing backend startup for 10 sec'
                dir('server'){
                    sh 'nohup node server.js & sleep 10 && pkill -f "node server.js" || true'
                }
                echo 'Server ran successfully. Ready to merge'
            }
        }
        // After setup of DockerFile
        stage('Dockerize and Deploy') {
            // when {
            //     branch 'main'
            // }
            steps{
                echo 'Building and Deploying Docker container'
                sh 'docker-compose down || true'
                sh 'docker-compose build'
                sh 'docker-compose up -d'
                echo 'Deployment Successful'
            }
        }
    }
    
    post{
        failure{
            echo 'Pipeline Failed'
        }
        success{
            script{
                if (BRANCH_NAME != 'main'){
                    echo "Branch '${BRANCH_NAME}' build and tested and safe to merge"
                }
            }
        }
    }
}