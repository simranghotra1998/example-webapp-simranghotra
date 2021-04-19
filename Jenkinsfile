def builderImage
def productionImage
def ACCOUNT_REGISTRY_PREFIX
def GIT_COMMIT_HASH

pipeline {
    agent any
    stages {
        stage('Checkout Source Code and Logging Into Registry') {
            steps {
                echo 'Logging Into the Private ECR Registry'
                script {
                    GIT_COMMIT_HASH = sh (script: "git log -n 1 --pretty=format:'%H'", returnStdout: true)
                    ACCOUNT_REGISTRY_PREFIX = "192687080956.dkr.ecr.us-east-2.amazonaws.com"
                    sh """
                    \$(aws ecr get-login --no-include-email --region us-east-2)
                    """
                }
            }
        }

        stage('Make A Builder Image') {
            steps {
                echo 'Starting to build the project builder docker image'
                script {
                    builderImage = docker.build("${ACCOUNT_REGISTRY_PREFIX}/example-webapp-simranghotra-builder:${GIT_COMMIT_HASH}", "-f ./Dockerfile.builder .")
                    builderImage.push()
                    builderImage.push("${env.GIT_BRANCH}")
                    builderImage.inside('-v $WORKSPACE:/output -u root') {
                        sh """
                           cd /output
                           lein uberjar
                        """
                    }
                }
            }
        }

        stage('Unit Tests') {
            steps {
                echo 'running unit tests in the builder image.'
                script {
                    builderImage.inside('-v $WORKSPACE:/output -u root') {
                    sh """
                       cd /output
                       lein test
                    """
                    }
                }
            }
        }

        stage('Build Production Image') {
            steps {
                echo 'Starting to build docker image'
                script {
                    productionImage = docker.build("${ACCOUNT_REGISTRY_PREFIX}/example-webapp-simranghotra:${GIT_COMMIT_HASH}")
                    productionImage.push()
                    productionImage.push("${env.GIT_BRANCH}")
                }
            }
        }

 
        stage('Deploy to Production fixed server') {
            when {
                branch 'release'
            }
            steps {
                echo 'Deploying release to production'
                script {
                    productionImage.push("deploy")
                    sh """
                       aws ec2 reboot-instances --region us-east-2 --instance-ids i-07cefeb2ffe967864
                    """
                }
            }
        }

        // stage('Integration Tests') {
        //     when {
        //         branch 'main'
        //     }
        //     steps {
        //         echo 'Deploy to test environment and run integration tests'
        //         script {
        //             TEST_ALB_LISTENER_ARN="arn:aws:elasticloadbalancing:us-east-2:192687080956:listener/app/testing-website/3809e8d8cacd3fc6/cf53c93534269986"
        //             sh """
        //             ./run-stack.sh example-webapp-simranghotra-test ${TEST_ALB_LISTENER_ARN}
        //             """
        //         }
        //         echo 'Running tests on the integration test environment'
        //         script {
        //             sh """
        //                curl -v http://testing-website-1318363585.us-east-2.elb.amazonaws.com | grep '<title>Welcome to example-webapp</title>'
        //                if [ \$? -eq 0 ]
        //                then
        //                    echo tests pass
        //                else
        //                    echo tests failed
        //                    exit 1
        //                fi
        //             """
        //         }
        //     }
        // }

 
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                script {
                    PRODUCTION_ALB_LISTENER_ARN="arn:aws:elasticloadbalancing:us-east-2:192687080956:listener/app/production-website/61f67e4045d504c4/6fedbb5c57225a37"
                    sh """
                    ./run-stack.sh example-webapp-simranghotra-production ${PRODUCTION_ALB_LISTENER_ARN}
                    """
                }
            }
        }
    }
}