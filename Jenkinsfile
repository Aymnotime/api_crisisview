pipeline {
  agent { label 'docker' }

  options {
    timestamps()
  }

  environment {
    REPO_URL = 'https://github.com/Aymnotime/api_crisisview.git'
    BRANCH   = 'main'

    SONARQUBE_SERVER = 'sonarqube'
    SONAR_SCANNER    = 'SonarScanner'
  }

  stages {
    stage('Checkout') {
      steps {
        dir('api_crisiview') {
          deleteDir()
          checkout([
            $class: 'GitSCM',
            branches: [[name: "*/${env.BRANCH}"]],
            userRemoteConfigs: [[url: env.REPO_URL]]
          ])
        }
      }
    }

    stage('Install') {
      steps {
        dir('api_crisiview') {
          sh 'node --version'
          sh 'npm ci'
        }
      }
    }

    stage('Test') {
      steps {
        dir('api_crisiview') {
          sh 'sh scripts/test-db-up.sh'
          withEnv([
            'DB_HOST=127.0.0.1',
            'DB_PORT=3306',
            'DB_NAME=incident_db',
            'DB_USER=root',
            'DB_PASSWORD=root'
          ]) {
            sh 'npm test'
          }
          sh 'sh scripts/test-db-down.sh'
        }
      }
    }

    stage('Sonar') {
      steps {
        dir('api_crisiview') {
          script {
            def scannerHome = tool(env.SONAR_SCANNER)
            withSonarQubeEnv(env.SONARQUBE_SERVER) {
              sh "${scannerHome}/bin/sonar-scanner -Dproject.settings=sonar-project.properties"
            }
          }
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: false
        }
      }
    }
  }
}
