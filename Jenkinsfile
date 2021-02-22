@Library('estl@v2') _

def notifyTargets = []

pipeline {
    agent any

    options {
        disableConcurrentBuilds()
    }

    stages {
        stage('Starting') {
            steps {
                runnerEnv {
                    echo sh(returnStdout: true, script: 'env')
                    notify(targets: notifyTargets, status: 'started', message: 'Started')
                    script {
                        currentBuild.description = "${env.IMAGE_TAG} ${env.GIT_SHA}"
                    }
                }
            }
        }

        stage('Build and Push') {
            steps {
                runner(task: 'build', env: ["IMAGE_PUSH=1"])
            }
        }
    }

    post {
        failure {
            notify(targets: notifyTargets, status: 'failure', message: 'Failure')
        }

        unstable {
            notify(targets: notifyTargets, status: 'unstable', message: 'Unstable')
        }

        success {
            notify(targets: notifyTargets, status: 'success', message: 'Success')
        }
    }
}
